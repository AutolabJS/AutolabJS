import java.io.*;
class Test
{
  public int test() {
    Seller x1=new Seller(100);
    if(x1.getQuantity()==100)
    {
      x1.setQuantity(20);
      if(x1.getQuantity()==20)
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
}
