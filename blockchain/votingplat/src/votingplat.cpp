#include <algorithm>
#include <votingplat.hpp>

ACTION votingplat::createvoter(name new_voter) {  // edited check please
  require_auth(get_self());
  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(new_voter.value);
  check(voting_itr == _voter.end(), "voter exist");
  /*
  itsc_table _itsc(get_self(), get_self().value);
  auto itsc_itr = _itsc.find(itsc);
  check(itsc_itr == _itsc.end(), "itsc linked already");
  */
  _voter.emplace(get_self(), [&](auto& new_voter_record) {
    new_voter_record.voter = new_voter;
    new_voter_record.is_active = true;
  });
  /*
  _itsc.emplace(get_self(), [&](auto& new_itsc_record){
    new_itsc_record.itsc = itsc;
    new_itsc_record.new_voter = new_voter;
  });
  */
  // Do we need to check both itsc? i guess
}

ACTION votingplat::createcamp(name owner, string campaign_name,
                              time_point start_time, time_point end_time) {
  check(has_auth(owner), "You are not authorized to use this account");
  check(start_time < end_time, "Invalid timing: Start is later than End ");
  check(start_time > current_time_point(),
        "Invalid timing: Campaign must start before the current time");

  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.begin();

  while (campaign_itr != _campaign.end()) {
    if (campaign_itr->campaign_name.compare(campaign_name) == 0) {
      break;
    }
    ++campaign_itr;
  }

  check(campaign_itr == _campaign.end(), "campaign exists");

  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(owner.value);
  check(voting_itr != _voter.end(), "owner not exist");
  check(voting_itr->is_active == true, "owner is not an active account");
  // campaign_table _campaign(get_self(), get_self().value);
  uint64_t _campaign_id = _campaign.available_primary_key();

  _campaign.emplace(get_self(), [&](auto& new_campaign_record) {
    new_campaign_record.id = _campaign_id;
    new_campaign_record.campaign_name = campaign_name;
    new_campaign_record.owner = owner;
    vector<campaign_choice> temp_choice_list;
    new_campaign_record.choice_list = temp_choice_list;
    new_campaign_record.start_time = start_time;
    new_campaign_record.end_time = end_time;
  });

  _voter.modify(voting_itr, get_self(), [&](auto& target_voter) {
    target_voter.owned_campaigns.push_back(_campaign_id);
  });
}

ACTION votingplat::addchoice(name owner, uint64_t campaign_id,
                             string new_choice) {
  check(has_auth(owner), "You are not authorized to use this account");
  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(owner.value);
  check(voting_itr != _voter.end(), "owner not exist");
  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.find(campaign_id);

  check(campaign_itr != _campaign.end(), "campaign not exist");
  check(campaign_itr->owner.value == owner.value,
        "You are not the owner of this campaign");
  check(campaign_itr->end_time > current_time_point(),
        "Campaign has ended already");
  check(campaign_itr->start_time > current_time_point(),
        "Campaign has already started");
  auto choice_itr = campaign_itr->choice_list.begin();
  while (choice_itr != campaign_itr->choice_list.end()) {
    if (choice_itr->choice.compare(new_choice) == 0) {
      break;
    }
    ++choice_itr;
  }
  check(choice_itr == campaign_itr->choice_list.end(), "duplicated choice");
  votingplat::campaign_choice _new_cp;
  _new_cp.choice = new_choice;
  _new_cp.result = 0;
  _campaign.modify(campaign_itr, get_self(), [&](auto& target_campaign) {
    target_campaign.choice_list.push_back(_new_cp);
  });
}
ACTION votingplat::addvoter(uint64_t campaign_id, name voter) {
  check(has_auth(get_self()), "only contract account can add vote");
  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.find(campaign_id);
  check(campaign_itr != _campaign.end(), "campaign not exist");
  check(campaign_itr->start_time > current_time_point(),
        "Campaign has already started");

  voter_table _voter(get_self(), get_self().value);

  auto voting_itr = _voter.find(voter.value);  // edited value
  check(voting_itr != _voter.end(), "voter not exist");
  check(voting_itr->is_active == true, "owner is not an active account");

  votingplat::voter_record record;
  record.campaign = campaign_id;
  record.is_vote = false;
  _voter.modify(voting_itr, get_self(), [&](auto& target_voter) {
    target_voter.votable_campaigns.push_back(record);
  });
}

ACTION votingplat::vote(uint64_t campaign_id, name voter, uint64_t choice_idx) {
  auto enter_time_point = current_time_point();
  check(has_auth(voter), "You are not authorized to use this account");
  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.find(campaign_id);
  check(campaign_itr != _campaign.end(), "campaign not exist");
  check((campaign_itr->choice_list).size() > choice_idx, "choice not exist");

  check(
      campaign_itr->start_time < enter_time_point,
      "Campaign has not started, enter time: " + enter_time_point.to_string());
  check(campaign_itr->end_time > enter_time_point,
        "Campaign has already ended, enter time: " +
            enter_time_point.to_string());

  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(voter.value);
  check(voting_itr != _voter.end(), "voter not exist");

  auto votable_campaigns_itr = voting_itr->votable_campaigns.begin();
  int voting_campaign_idx = 0;
  while (votable_campaigns_itr != voting_itr->votable_campaigns.end()) {
    if (votable_campaigns_itr->campaign == campaign_id) {
      break;
    }
    ++voting_campaign_idx;
    ++votable_campaigns_itr;
  }
  check(votable_campaigns_itr != voting_itr->votable_campaigns.end(),
        "voter cannot vote this campaign");

  // check(find(voting_itr->votable_campaigns.begin(),
  //            voting_itr->votable_campaigns.end(),
  //            campaign_id) != voting_itr->votable_campaigns.end(),
  //       "voter cannot vote this campaign");

  check(votable_campaigns_itr->is_vote == false, "you have voted already");

  _campaign.modify(campaign_itr, get_self(), [&](auto& target_campaign) {
    ++target_campaign.choice_list[choice_idx].result;
  });

  _voter.modify(voting_itr, get_self(), [&](auto& target_voter) {
    target_voter.votable_campaigns[voting_campaign_idx].is_vote = true;
  });
}

ACTION votingplat::deletecamp(name owner, uint64_t campaign_id) {
  check(has_auth(owner), "You are not authorized to use this account");
  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.find(campaign_id);
  check(campaign_itr != _campaign.end(), "campaign not exist");
  check(campaign_itr->owner.value == owner.value, "You are not the owner");
  check(campaign_itr->start_time > current_time_point(),
        "Campaign has already started");
  _campaign.erase(campaign_itr);
}

ACTION votingplat::updatevoter(name voter, bool active) {
  check(has_auth(get_self()), "Only admin can update one's voting account");
  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(voter.value);
  check(voting_itr != _voter.end(), "voter not exist");

  _voter.modify(voting_itr, get_self(),
                [&](auto& target_voter) { target_voter.is_active = false; });
}

ACTION votingplat::deletevoter(name voter) {
  check(has_auth(get_self()), "Only admin can update one's voting account");
  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(voter.value);
  check(voting_itr != _voter.end(), "voter not exist");
  _voter.erase(voting_itr);
  check(voting_itr != _voter.end(), "Invalid : voter was not deleted properly");
}

ACTION votingplat::clear() {
  check(has_auth(get_self()), "Only admin can use this");
  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.begin();
  while (voting_itr != _voter.end()) {
    auto next_itr = ++voting_itr;
    _voter.erase(voting_itr);
    voting_itr = next_itr;
  }

  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.begin();
  while (campaign_itr != _campaign.end()) {
    auto next_itr = ++campaign_itr;
    _campaign.erase(campaign_itr);
    campaign_itr = next_itr;
  }
}

EOSIO_DISPATCH(
    votingplat,
    (createvoter)(createcamp)(addchoice)(addvoter)(vote)(deletecamp)(deletevoter)(updatevoter)(clear))
