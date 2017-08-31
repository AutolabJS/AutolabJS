public class Test extends AbstractTest {
  public int test() {
		int score = 0;
		if (runTest(SellerTest.class, "sell"))
		   score = 1;

		return score;
	}
}
