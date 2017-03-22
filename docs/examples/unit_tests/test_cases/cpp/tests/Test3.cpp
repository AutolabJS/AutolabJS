#include "Buyer.hpp"

using namespace std;

int test()
{
    Buyer buyer(100);
    if(buyer.getCash()==100)
    {
      buyer.setCash(20);
      if(buyer.getCash()==20)
      {
        return 1;
      }
      else
      {
        return 0;
      }
    }
    else
    {
      return 0;
    }
}
