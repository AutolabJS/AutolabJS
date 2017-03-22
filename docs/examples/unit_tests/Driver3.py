from Test import Test

if __name__ == '__main__':

	check = Test()

	try:
		score = check.test()
		print(score)

	except Exception:
		print(125)
	else:
		pass

