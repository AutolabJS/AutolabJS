from Seller import Seller

class Test:
	def test(self):
		seller = Seller(2)
		score = 0
		if seller.sell()==1:
			if seller.getQuantity()==1:
				seller.setQuantity(0)
				if seller.sell()==0:
					if seller.getQuantity()==0:
						score = 1
						return score
		else:
			return 0

