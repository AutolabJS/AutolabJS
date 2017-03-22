from Seller import Seller

class Test:
	def test(self):
		seller = Seller(100)
		if seller.getQuantity()==100:
			seller.setQuantity(20)
			if seller.getQuantity()==20:
				return 1
			else:
				return 0
		else:
			return 0
