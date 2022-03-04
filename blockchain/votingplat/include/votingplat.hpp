#include <eosio/eosio.hpp>
#include <eosio/system.hpp>

using namespace std;
using namespace eosio;

static constexpr name none = name("none");

CONTRACT votingplat : public contract {
 public:
  using contract::contract;

  ACTION createvoter(name new_voter);
  ACTION createcamp(name owner, string campaign_name, string start_time_string,
                    string end_time_string);
  ACTION addchoice(name owner, uint64_t campaign_id, string new_choice);
  ACTION delchoice(name owner, uint64_t campaign_id, uint64_t choice_idx);
  ACTION addvoter(uint64_t campaign_id, name voter);
  ACTION delvotable(uint64_t campaign_id, uint64_t voter_idx);
  // ACTION addvoteritsc(name owner, uint64_t campaign_id, string itsc);
  ACTION vote(uint64_t campaign_id, name voter, uint64_t choice_idx);
  ACTION deletecamp(name owner, uint64_t campaign_id);

  // --- Voter maniputation --- //
  ACTION updatevoter(name voter, bool active);
  ACTION deletevoter(name voter);

  ACTION clear();

  struct voter_record {
    uint64_t campaign;
    bool is_vote;
  };

  struct campaign_choice {
    string choice;
    uint64_t result;
  };

  TABLE campaign_list {
    uint64_t id;
    string campaign_name;
    name owner;
    time_point start_time;
    time_point end_time;
    vector<name> voter_list;
    vector<campaign_choice> choice_list;
    auto primary_key() const { return id; }
  };

  typedef multi_index<name("campaign"), campaign_list> campaign_table;

  TABLE voter_list {
    name voter;
    vector<uint64_t> owned_campaigns;
    vector<voter_record> votable_campaigns;
    bool is_active;
    auto primary_key() const { return voter.value; }
  };

  typedef multi_index<name("voter"), voter_list> voter_table;

 private:
};
