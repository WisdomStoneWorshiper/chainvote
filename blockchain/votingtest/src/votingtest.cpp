#include <votingtest.hpp>

ACTION votingtest::addcandidate(name new_candidate) {
  require_auth(get_self());
  voting_result_table _voting(get_self(), get_self().value);
  auto voting_itr = _voting.find(new_candidate.value);
  check(voting_itr == _voting.end(), "candidate exist");
  _voting.emplace(get_self(), [&](auto& new_candidate_record) {
    new_candidate_record.candidate = new_candidate;
    new_candidate_record.vote_count = 0;
  });
}

ACTION votingtest::addvoter(name new_voter) {
  require_auth(get_self());
  voter_list_table _voter(get_self(), get_self().value);
  auto voting_itr = _voter.find(new_voter.value);
  check(voting_itr == _voter.end(), "voter exist");
  _voter.emplace(get_self(), [&](auto& new_voter_record) {
    new_voter_record.voter = new_voter;
  });

  voter_record_list_table _record(get_self(), get_self().value);
  _record.emplace(get_self(), [&](auto& new_record) {
    new_record.voter = new_voter;
    new_record.choice = none;
  });
}

ACTION votingtest::vote(name voter, name candidate) {
  check(has_auth(voter), "You are not voter.");

  voter_list_table _voter(get_self(), get_self().value);
  auto voter_itr = _voter.find(voter.value);
  check(voter_itr != _voter.end(), "You cannot voter");

  voting_result_table _voting(get_self(), get_self().value);
  auto voting_itr = _voting.find(candidate.value);
  check(voting_itr != _voting.end(), "candidate is not exist");

  voter_record_list_table _record(get_self(), get_self().value);
  auto record_itr = _record.find(voter.value);
  check(record_itr->choice == none, "You have voted already");

  _voting.modify(voting_itr, get_self(),
                 [&](auto& ballot) { ++ballot.vote_count; });

  _record.modify(record_itr, get_self(),
                 [&](auto& record) { record.choice = candidate; });
}

ACTION votingtest::unvote(name voter, name candidate) {
  check(has_auth(voter), "You are not owner of voter account.");

  voter_list_table _voter(get_self(), get_self().value);
  auto voter_itr = _voter.find(voter.value);
  check(voter_itr != _voter.end(), "You cannot voter");

  voting_result_table _voting(get_self(), get_self().value);
  auto voting_itr = _voting.find(candidate.value);
  check(voting_itr != _voting.end(), "candidate is not exist");

  voter_record_list_table _record(get_self(), get_self().value);
  auto record_itr = _record.find(voter.value);
  check(record_itr->choice == candidate, "You didn't vote before");

  _voting.modify(voting_itr, get_self(),
                 [&](auto& ballot) { --ballot.vote_count; });

  _record.modify(record_itr, get_self(),
                 [&](auto& record) { record.choice = none; });
}

ACTION votingtest::clear() {
  require_auth(get_self());

  voting_result_table _voting(get_self(), get_self().value);
  auto voting_itr = _voting.begin();
  while (voting_itr != _voting.end()) {
    voting_itr = _voting.erase(voting_itr);
  }

  voter_list_table _voter(get_self(), get_self().value);
  auto voter_itr = _voter.begin();
  while (voter_itr != _voter.end()) {
    voter_itr = _voter.erase(voter_itr);
  }

  voter_record_list_table _record(get_self(), get_self().value);
  auto record_itr = _record.begin();
  while (record_itr != _record.end()) {
    record_itr = _record.erase(record_itr);
  }
}

ACTION votingtest::testfuc() {
  test_table _test(get_self(), get_self().value);
  vector<uint8_t> temp_list = {1, 2, 3, 4};

  _test.emplace(get_self(), [&](auto& new_record) {
    new_record.id = _test.available_primary_key();
    new_record.result = temp_list;
  });
}

EOSIO_DISPATCH(votingtest,
               (addcandidate)(vote)(unvote)(clear)(addvoter)(testfuc))
