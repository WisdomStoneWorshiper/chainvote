#include <eosio/eosio.hpp>

using namespace std;
using namespace eosio;

CONTRACT votingtest : public contract {
 public:
  using contract::contract;

  ACTION addcandidate(name new_candidate);
  ACTION vote(name candidate);
  ACTION clear();

  TABLE voting_result {
    name candidate;
    uint64_t vote_count;
    auto primary_key() const { return candidate.value; }
  };
  typedef multi_index<name("votingresult"), voting_result> voting_result_table;
};
