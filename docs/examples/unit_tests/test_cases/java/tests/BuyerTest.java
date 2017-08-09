import static org.junit.Assert.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import static org.hamcrest.CoreMatchers.*;
/**
 * The test class BuyerTest to test Buyer class.
 *
 * @author  Ankshit Jain
 * @version 09-August-2017
 */
public class BuyerTest
{
    private Buyer x1;
    private Seller x;
    /**
     * Sets up the test fixture.
     *
     * Called before every test case method.
     */
    @Before
    public void setUp()
    {
        x1 = new Buyer(2);
        x = new Seller(10);
    }

    /**
     * Tears down the test fixture.
     *
     * Called after every test case method.
     */
    @After
    public void tearDown()
    {
        x1 = null;
        x = null;
    }
    
    /**
     * This test checks the functionality of getCash() and setCash(int cash) methods.
     */
    @Test
    public void getSet()
    {
        assertThat(x1.getCash(), is(2));
        x1.setCash(1);
        assertThat(x1.getCash(), is(1));
    }
    
    /**
     * This test checks the functionality of buy(Seller x) method.
     */
    @Test
    public void buy()
    {
        x1.buy(x);
        assertThat(x1.getCash(), is(1));
        x1.setCash(0);
        x1.buy(x);
        assertThat(x1.getCash(), is(0));
        x1.setCash(1);
        x.setQuantity(0);
        x1.buy(x);
        assertThat(x1.getCash(), is(1));
    }
}
