#include <eosio/eosio.hpp>

using namespace std;
using namespace eosio;

CONTRACT votingtest : public contract {
 public:
  using contract::contract;

  ACTION addvoter(name new_voter);

  ACTION addcandidate(name new_candidate);
  ACTION vote(name voter, name candidate);
  ACTION unvote(name voter, name candidate);
  ACTION clear();

  TABLE voting_result {
    name candidate;
    uint64_t vote_count;
    auto primary_key() const { return candidate.value; }
  };

  TABLE voter_list {
    name voter;
    auto primary_key() const { return voter.value; }
  };

  typedef multi_index<name("votingresult"), voting_result> voting_result_table;

  typedef multi_index<name("voterlist"), voter_list> voter_list_table;
};
