# Enter your code here. Read input from STDIN. Print output to STDOUT
class Node:
    def __init__(self,key):
        self.left=None
        self.right=None
        self.val=key

def insert(node,key):
    if node is None:
        return Node(key)
    if key<=node.val:
        node.left = insert(node.left,key)
    else:
        node.right = insert(node.right,key)
    return node

def inorder(root):
    if root:
        inorder(root.left)
        print root.val,
        inorder(root.right)

def preorder(root):
    if root:
        print root.val,
        preorder(root.left)
        preorder(root.right)

def postorder(root):
    if root:
        postorder(root.left)
        postorder(root.right)
        print root.val,

n = input()

lis=map(int,raw_input().strip().split(' '))
r=Node(lis[0])
for i in range(n-1):
    k = lis[i+1]
    r = insert(r,k)

inorder(r)
print
preorder(r)
print
postorder(r)
