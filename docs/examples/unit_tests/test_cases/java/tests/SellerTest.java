import static org.junit.Assert.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import static org.hamcrest.CoreMatchers.*;
/**
 * The test class SellerTest for testing class Seller.
 *
 * @author  Ankshit Jain
 * @version 09-August-2017
 */
public class SellerTest
{
    private Seller x1;
    /**
     * Sets up the test fixture.
     *
     * Called before every test case method.
     */
    @Before
    public void setUp()
    {
        x1 = new Seller(2);
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
    }
    
    /**
     * This test checks the functionality of getQuantity() and setQuantity(int quantity) methods.
     */
    @Test
    public void getSet()
    {
        assertThat(x1.getQuantity(), is(2));
        x1.setQuantity(1);
        assertThat(x1.getQuantity(), is(1));
    }
    
    /**
     * This test checks the functionality of sell() method.
     */
    @Test
    public void sell()
    {
        assertThat(x1.sell(), is(1));
        assertThat(x1.getQuantity(), is(1));
        x1.setQuantity(0);
        assertThat(x1.sell(), is(0));
        assertThat(x1.getQuantity(), is(0));
    }
}
