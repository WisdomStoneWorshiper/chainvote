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

ACTION votingtest::vote(name candidate) {
  voting_result_table _voting(get_self(), get_self().value);
  auto voting_itr = _voting.find(candidate.value);
  check(voting_itr != _voting.end(), "candidate is not exist");

  _voting.modify(voting_itr, get_self(),
                 [&](auto& ballot) { ++ballot.vote_count; });
}

ACTION votingtest::unvote(name candidate) {
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

EOSIO_DISPATCH(votingtest, (addcandidate)(vote)(clear))
