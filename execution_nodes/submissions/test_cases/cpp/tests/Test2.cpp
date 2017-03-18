#include "Seller.hpp"

using namespace std;

int test()
{
    Seller seller(2);
    int score=0;
    if(seller.sell()==1)
    {
      if(seller.getQuantity()==1)
      {
        seller.setQuantity(0);
        if(seller.sell()==0)
        {
          if(seller.getQuantity()==0)
          {
            score=1;
          }
        }
      }
    }
    return score;
}
