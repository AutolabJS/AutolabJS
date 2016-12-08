#include "Seller.hpp"

Seller::Seller(int quantity)
{
    this->quantity=quantity;
}

int Seller::getQuantity()
{
    return quantity;
}

void Seller::setQuantity(int quantity)
{
    this->quantity=quantity;
}

int Seller::sell()
{
    if(quantity>0)
    {
      quantity--;
      return 1;
    }
    else
    {
      return 0;
    }
}
