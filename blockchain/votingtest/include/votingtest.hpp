#include <eosio/eosio.hpp>

using namespace std;
using namespace eosio;

static constexpr name none = name("none");

CONTRACT votingtest : public contract {
 public:
  using contract::contract;

  ACTION addvoter(name new_voter);

  ACTION addcandidate(name new_candidate);
  ACTION vote(name voter, name candidate);
  ACTION unvote(name voter, name candidate);
  ACTION clear();

  ACTION testfuc();

  TABLE voting_result {
    name candidate;
    uint64_t vote_count;
    auto primary_key() const { return candidate.value; }
  };

  TABLE voter_list {
    name voter;
    auto primary_key() const { return voter.value; }
  };

  TABLE test_list {
    uint64_t id;
    vector<uint8_t> result;
    auto primary_key() const { return id; }
  };

  typedef multi_index<name("testing"), test_list> test_table;

  typedef multi_index<name("votingresult"), voting_result> voting_result_table;

  typedef multi_index<name("voterlist"), voter_list> voter_list_table;

 private:
  TABLE voter_record_list {
    name voter;
    name choice;
    auto primary_key() const { return voter.value; }
  };

  typedef multi_index<name("recordlist"), voter_record_list>
      voter_record_list_table;
};
