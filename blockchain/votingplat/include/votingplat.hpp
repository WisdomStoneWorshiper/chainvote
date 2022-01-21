#include <eosio/eosio.hpp>

using namespace std;
using namespace eosio;

static constexpr name none = name("none");

CONTRACT votingplat : public contract {
 public:
  using contract::contract;

  ACTION createvoter(name new_voter);
  ACTION createcamp(name owner, string campaign_name);
  ACTION addchoice(name owner, uint64_t campaign_id, string new_choice);
  ACTION addvoter(name owner, uint64_t campaign_id, name voter);
  ACTION vote(uint64_t campaign_id, name voter, uint64_t choice_idx);
  ACTION deletecamp(name owner, uint64_t campaign_id);

  // ACTION addvoter(name new_voter);

  // ACTION addcandidate(name new_candidate);
  // ACTION vote(name voter, name candidate);
  // ACTION unvote(name voter, name candidate);
  // ACTION clear();

  // ACTION testfuc();

  TABLE campaign_list {
    uint64_t id;
    string campaign_name;
    name owner;
    vector<string> choice_list;
    vector<uint64_t> result;
    auto primary_key() const { return id; }
  };

  typedef multi_index<name("campaign"), campaign_list> campaign_table;

  TABLE voter_list {
    name voter;
    vector<uint64_t> owned_campaigns;
    vector<uint64_t> votable_campaigns;
    auto primary_key() const { return voter.value; }
  };

  typedef multi_index<name("voter"), voter_list> voter_table;

 private:
  TABLE voter_record_list {
    name voter;
    name choice;
    auto primary_key() const { return voter.value; }
  };

  typedef multi_index<name("recordlist"), voter_record_list>
      voter_record_list_table;
};
