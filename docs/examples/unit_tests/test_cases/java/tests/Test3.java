public class Test extends AbstractTest {
  public int test() {
		int score = 0;
		if (runTest(BuyerTest.class, "getSet"))
		   score = 1;

		return score;
	}
}
