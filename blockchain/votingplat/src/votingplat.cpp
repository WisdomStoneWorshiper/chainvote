#include <algorithm>
#include <votingplat.hpp>

ACTION votingplat::createvoter(name new_voter) {
  require_auth(get_self());
  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(new_voter.value);
  check(voting_itr == _voter.end(), "voter exist");
  _voter.emplace(get_self(), [&](auto& new_voter_record) {
    new_voter_record.voter = new_voter;
  });
}

ACTION votingplat::createcamp(name owner, string campaign_name) {
  check(has_auth(owner), "You are not authorized to use this account");
  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(owner.value);
  check(voting_itr != _voter.end(), "owner not exist");
  campaign_table _campaign(get_self(), get_self().value);
  uint64_t _campaign_id = _campaign.available_primary_key();

  _campaign.emplace(get_self(), [&](auto& new_campaign_record) {
    new_campaign_record.id = _campaign_id;
    new_campaign_record.campaign_name = campaign_name;
    new_campaign_record.owner = owner;
    vector<string> temp_str_list;
    new_campaign_record.choice_list = temp_str_list;
    vector<uint64_t> temp_result;
    new_campaign_record.result = temp_result;
  });

  _voter.modify(voting_itr, get_self(), [&](auto& target_voter) {
    target_voter.owned_campaigns.push_back(_campaign_id);
  });
}

ACTION votingplat::addchoice(name owner, uint64_t campaign_id,
                             string new_choice) {
  check(has_auth(owner), "You are not authorized to use this account");
  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.find(campaign_id);
  check(campaign_itr != _campaign.end(), "campaign not exist");
  _campaign.modify(campaign_itr, get_self(), [&](auto& target_campaign) {
    target_campaign.choice_list.push_back(new_choice);
    target_campaign.result.push_back(0);
  });
}
ACTION votingplat::addvoter(name owner, uint64_t campaign_id, name voter) {
  check(has_auth(owner), "You are not authorized to use this account");
  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.find(campaign_id);
  check(campaign_itr != _campaign.end(), "campaign not exist");

  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(owner.value);
  check(voting_itr != _voter.end(), "owner not exist");

  voting_itr = _voter.find(voter.value);
  check(voting_itr != _voter.end(), "voter not exist");

  _voter.modify(voting_itr, get_self(), [&](auto& target_voter) {
    target_voter.votable_campaigns.push_back(campaign_id);
  });
}

ACTION votingplat::vote(uint64_t campaign_id, name voter, uint64_t choice_idx) {
  check(has_auth(voter), "You are not authorized to use this account");
  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.find(campaign_id);
  check(campaign_itr != _campaign.end(), "campaign not exist");
  check((campaign_itr->choice_list).size() > choice_idx, "choice not exist");

  voter_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(voter.value);
  check(voting_itr != _voter.end(), "voter not exist");
  check(find(voting_itr->votable_campaigns.begin(),
             voting_itr->votable_campaigns.end(),
             campaign_id) != voting_itr->votable_campaigns.end(),
        "voter cannot vote this campaign");

  _campaign.modify(campaign_itr, get_self(), [&](auto& target_campaign) {
    ++target_campaign.result[choice_idx];
  });

  votingplat::voter_actions record;
  record.campaign = campaign_itr->campaign_name;
  record.action_time = current_time_point();

  _voter.modify(voting_itr, get_self(), [&](auto& target_voter) {
    target_voter.records.push_back(record); 
  });
}

ACTION votingplat::deletecamp(name owner, uint64_t campaign_id) {
  check(has_auth(owner), "You are not authorized to use this account");
  campaign_table _campaign(get_self(), get_self().value);
  auto campaign_itr = _campaign.find(campaign_id);
  check(campaign_itr != _campaign.end(), "campaign not exist");

  _campaign.erase(campaign_itr);
}

EOSIO_DISPATCH(votingplat,
               (createvoter)(createcamp)(addchoice)(addvoter)(vote)(deletecamp))
