public class Test extends AbstractTest {
  public int test() {
		int score = 0;
		if (runTest(BuyerTest.class, "buy"))
		   score = 1;

		return score;
	}
}
