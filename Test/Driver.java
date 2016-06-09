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
    catch(RuntimeException e)
    {
      System.out.println("error");
    }
    catch(Throwable e)
    {
      System.out.println("0");
    }

  }
}
