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
}

ACTION votingtest::vote(name voter, name candidate) {
  check(has_auth(voter), "You are not voter.");

  voter_list_table _voter(get_self(), get_self().value);
  auto voter_itr = _voter.find(voter.value);
  check(voter_itr != _voter.end(), "You cannot voter");

  voting_result_table _voting(get_self(), get_self().value);
  auto voting_itr = _voting.find(candidate.value);
  check(voting_itr != _voting.end(), "candidate is not exist");

  _voting.modify(voting_itr, get_self(),
                 [&](auto& ballot) { ++ballot.vote_count; });
}

ACTION votingtest::unvote(name voter, name candidate) {
  check(has_auth(voter), "You are not voter.");

  voter_list_table _voter(get_self(), get_self().value);
  auto voter_itr = _voter.find(voter.value);
  check(voter_itr != _voter.end(), "You cannot voter");

  voting_result_table _voting(get_self(), get_self().value);
  auto voting_itr = _voting.find(candidate.value);
  check(voting_itr != _voting.end(), "candidate is not exist");

  _voting.modify(voting_itr, get_self(),
                 [&](auto& ballot) { --ballot.vote_count; });
}

ACTION votingtest::clear() {
  require_auth(get_self());

  voting_result_table _voting(get_self(), get_self().value);

  // Delete all records in _messages table
  auto voting_itr = _voting.begin();
  while (voting_itr != _voting.end()) {
    voting_itr = _voting.erase(voting_itr);
  }
}

EOSIO_DISPATCH(votingtest, (addcandidate)(vote)(clear)(addvoter))
