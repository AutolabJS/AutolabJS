from Buyer import Buyer
from Seller import Seller

class Test:
	def test(self):
		buyer = Buyer(2)
		seller = Seller(10)
		score = 0

		buyer.buy(seller)
		if buyer.getCash()==1 and seller.getQuantity() == 9:
			seller.setQuantity(0)
			buyer.buy(seller)
			if buyer.getCash()==1:
				score = 1

		return score
