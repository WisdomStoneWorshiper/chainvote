#include <eosio/eosio.hpp>
#include <eosio/system.hpp>

using namespace std;
using namespace eosio;

static constexpr name none = name("none");

CONTRACT votingplat : public contract {
 public:
  using contract::contract;

  ACTION createvoter(name new_voter, string itsc);
  ACTION createcamp(name owner, string campaign_name, time_point start_time, time_point end_time);
  ACTION addchoice(name owner, uint64_t campaign_id, string new_choice);
  ACTION addvoter(name owner, uint64_t campaign_id, name voter);
  ACTION addvoteritsc(name owner, uint64_t campaign_id, string itsc);
  ACTION vote(uint64_t campaign_id, name voter, uint64_t choice_idx);
  ACTION deletecamp(name owner, uint64_t campaign_id);

  // --- Voter maniputation --- //
  ACTION updatevoter(name voter, bool active);
  ACTION deletevoter(name voter);



  // ACTION addvoter(name new_voter);

  // ACTION addcandidate(name new_candidate);
  // ACTION vote(name voter, name candidate);
  // ACTION unvote(name voter, name candidate);
  // ACTION clear();

  // ACTION testfuc();

  struct voter_actions {
    string campaign;
    time_point action_time;
  };


  TABLE campaign_list {
    uint64_t id;
    string campaign_name;
    name owner;
    time_point start_time;
    time_point end_time;
    vector<string> choice_list;
    vector<uint64_t> result;
    auto primary_key() const { return id; }
  };

  typedef multi_index<name("campaign"), campaign_list> campaign_table;

  TABLE voter_list {
    name voter;
    vector<uint64_t> owned_campaigns;
    vector<uint64_t> votable_campaigns;
    vector<voter_actions> records;
    bool is_active;
    auto primary_key() const { return voter.value; }
  };

  typedef multi_index<name("voter"), voter_list> voter_table;

 private:
  TABLE itsc_list {
    string itsc;
    name voter;
    auto primary_key() const { return voter.value};
  }

  typedef multi_index<name("itsc"), itsc_list> itsc_table;
};
