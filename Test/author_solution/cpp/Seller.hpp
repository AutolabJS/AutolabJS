#include <iostream>

using namespace std;

class Seller
{
  private:
  	int quantity;

  public:
  Seller(int quantity);
  int getQuantity();
  void setQuantity(int quantity);
  int sell();
};
