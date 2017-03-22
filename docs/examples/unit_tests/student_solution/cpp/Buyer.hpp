#include "Seller.hpp"

using namespace std;

class Buyer
{
  private:
	int cash;

  public:
	Buyer(int cash);
	int getCash();
	void setCash(int cash);
	void buy(Seller x);
};
