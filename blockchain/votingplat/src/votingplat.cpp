#include <algorithm>
#include <votingplat.hpp>

ACTION votingplat::createvoter(name new_voter) {  // edited check please
  require_auth(get_self());
  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(new_voter.value);
  check(voting_itr == _voter.end(), "voter exist");
  _voter.emplace(get_self(), [&](auto& new_voter_record) {
    new_voter_record.voter = new_voter;
    new_voter_record.is_active = true;
  });
}

ACTION votingplat::createcamp(name owner, string campaign_name,
                              string start_time_string,
                              string end_time_string) {
  time_point start_time =
      eosio::time_point().from_iso_string(start_time_string);
  time_point end_time = eosio::time_point().from_iso_string(end_time_string);
  check(has_auth(owner), "You are not authorized to use this account");
  check(start_time < end_time, "Invalid timing: Start is later than End");
  check(start_time > current_time_point(),
        "Invalid timing: Campaign must start before the current time, current "
        "time: " +
            current_time_point().to_string() +
            " start time: " + start_time.to_string());

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
    vector<name> temp_voter_list;
    new_campaign_record.voter_list = temp_voter_list;
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

ACTION votingplat::delchoice(name owner, uint64_t campaign_id,
                             uint64_t choice_idx) {
  check(has_auth(owner), "You are not authorized to use this account");

  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(owner.value);
  check(voting_itr != _voter.end(), "owner not exist");
  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.find(campaign_id);

  check(campaign_itr != _campaign.end(), "campaign not exist");
  check(choice_idx < campaign_itr->choice_list.size(),
        "choice index out of range");
  check(campaign_itr->owner.value == owner.value,
        "You are not the owner of this campaign");
  check(campaign_itr->end_time > current_time_point(),
        "Campaign has ended already");
  check(campaign_itr->start_time > current_time_point(),
        "Campaign has already started");
  _campaign.modify(campaign_itr, get_self(), [&](auto& target_campaign) {
    target_campaign.choice_list.erase(target_campaign.choice_list.begin() +
                                      choice_idx);
  });
}

ACTION votingplat::addvoter(uint64_t campaign_id, name voter) {
  check(has_auth(get_self()), "only contract account can add vote");
  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.find(campaign_id);
  check(campaign_itr != _campaign.end(), "campaign not exist");
  check(campaign_itr->start_time > current_time_point(),
        "Campaign has already started");

  auto campaign_voter_list_itr = campaign_itr->voter_list.begin();

  while (campaign_voter_list_itr != campaign_itr->voter_list.end()) {
    check(*campaign_voter_list_itr != voter, "voter added already");
  }

  voter_table _voter(get_self(), get_self().value);

  auto voting_itr = _voter.find(voter.value);  // edited value
  check(voting_itr != _voter.end(), "voter not exist");
  check(voting_itr->is_active == true, "voter is not an active account");

  votingplat::voter_record record;
  record.campaign = campaign_id;
  record.is_vote = false;
  _voter.modify(voting_itr, get_self(), [&](auto& target_voter) {
    target_voter.votable_campaigns.push_back(record);
  });

  _campaign.modify(campaign_itr, get_self(), [&](auto& target_campaign) {
    target_campaign.voter_list.push_back(voting_itr->voter);
  });
}

ACTION votingplat::delvotable(uint64_t campaign_id, uint64_t voter_idx) {
  check(has_auth(get_self()), "only contract account can del votable");
  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.find(campaign_id);
  check(campaign_itr != _campaign.end(), "campaign not exist");
  check(campaign_itr->start_time > current_time_point(),
        "Campaign has already started");
  check(voter_idx < campaign_itr->voter_list.size(),
        "voter index out of range");

  name voter_del = campaign_itr->voter_list[voter_idx];

  voter_table _voter(get_self(), get_self().value);

  auto voting_itr = _voter.find(voter_del.value);  // edited value
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

  _campaign.modify(campaign_itr, get_self(), [&](auto& target_campaign) {
    target_campaign.voter_list.erase(target_campaign.voter_list.begin() +
                                     voter_idx);
  });

  _voter.modify(voting_itr, get_self(), [&](auto& target_voter) {
    target_voter.votable_campaigns.erase(
        target_voter.votable_campaigns.begin() + voting_campaign_idx);
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

  voter_table _voter(get_self(), get_self().value);

  auto _owner = _voter.find(campaign_itr->owner.value);
  auto owner_itr = _owner->owned_campaigns.begin();
  while (owner_itr != _owner->owned_campaigns.end()) {
    if (*owner_itr == campaign_itr->id) {
      _voter.modify(_owner, get_self(), [&](auto& target_owner) {
        target_owner.owned_campaigns.erase(owner_itr);
      });
      break;
    }
    ++owner_itr;
  }

  auto votable_itr = campaign_itr->voter_list.begin();
  while (votable_itr != campaign_itr->voter_list.end()) {
    auto voter_itr = _voter.find(votable_itr->value);

    auto votable_campaigns_itr = voter_itr->votable_campaigns.begin();
    while (votable_campaigns_itr != voter_itr->votable_campaigns.end()) {
      if (votable_campaigns_itr->campaign == campaign_itr->id) {
        _voter.modify(voter_itr, get_self(), [&](auto& target_voter) {
          target_voter.votable_campaigns.erase(votable_campaigns_itr);
        });
        break;
      }
      ++votable_campaigns_itr;
    }
    ++votable_itr;
  }
  _campaign.erase(campaign_itr);
}

ACTION votingplat::updatevoter(name voter, bool active) {
  check(has_auth(get_self()), "Only admin can update one's voting account");
  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(voter.value);
  check(voting_itr != _voter.end(), "voter not exist");

  _voter.modify(voting_itr, get_self(),
                [&](auto& target_voter) { target_voter.is_active = active; });
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
    voting_itr = _voter.erase(voting_itr);
  }

  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.begin();
  while (campaign_itr != _campaign.end()) {
    campaign_itr = _campaign.erase(campaign_itr);
  }
}

EOSIO_DISPATCH(
    votingplat,
    (createvoter)(createcamp)(addchoice)(delchoice)(addvoter)(delvotable)(vote)(deletecamp)(deletevoter)(updatevoter)(clear))
