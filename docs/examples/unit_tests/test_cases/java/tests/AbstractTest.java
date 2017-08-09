import org.junit.runner.JUnitCore;
import org.junit.runner.Request;
import org.junit.runner.Result;

/**
 * Common code used for running tests in Test class.
 * 
 * @author Prasad Talasila
 * @version 03-July-2017
 */
public abstract class AbstractTest {
	/**
	 * Run the unit test named class.methodName() and return the binary result
	 */
	public boolean runTest(Class<?> clazz, String methodName) {
		Request request = Request.method(clazz, methodName);
		JUnitCore core = new JUnitCore();
		Result result = core.run(request);
		return result.wasSuccessful();
	}
		/**
		 * Run all the existing unit tests in clazz and return the binary result
		 * if all the tests are successful
		 */
		public boolean runTest(Class<?> clazz) {
			JUnitCore core = new JUnitCore();
			Result result = core.run(clazz);
			return result.wasSuccessful();
		}
}
