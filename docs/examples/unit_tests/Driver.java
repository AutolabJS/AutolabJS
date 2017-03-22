import java.io.*;
class Driver
{
  public static void main(String args[])
  {
    Test x=new Test();
    int score;
    try
    {
      score = x.test();
      System.out.println(score);
    }
    catch(Throwable e)
    {
      System.out.println("125");
    }

  }
}
