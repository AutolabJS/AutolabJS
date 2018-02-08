import java.io.*;
import java.util.*;
import java.text.*;
import java.math.*;
import java.util.regex.*;

class BTNode
{
    BTNode left, right;
    int data;

    /* Constructor */
    public BTNode()
    {
        left = null;
        right = null;
        data = 0;
    }
    /* Constructor */
    public BTNode(int n)
    {
        left = null;
        right = null;
        data = n;
    }
    /* Function to set left node */
    public void setLeft(BTNode n)
    {
        left = n;
    }
    /* Function to set right node */
    public void setRight(BTNode n)
    {
        right = n;
    }
    /* Function to get left node */
    public BTNode getLeft()
    {
        return left;
    }
    /* Function to get right node */
    public BTNode getRight()
    {
        return right;
    }
    /* Function to set data to node */
    public void setData(int d)
    {
        data = d;
    }
    /* Function to get data from node */
    public int getData()
    {
        return data;
    }
}

/* Class BT */
class BT
{
    private BTNode root;

    /* Constructor */
    public BT()
    {
        root = null;
    }
    /* Function to check if tree is empty */
    public boolean isEmpty()
    {
        return root == null;
    }
    /* Functions to insert data */
    public void insert(int data)
    {
        root = insert(root, data);
    }
    /* Function to insert data recursively */
    private BTNode insert(BTNode node, int data)
    {
        if (node == null)
            node = new BTNode(data);
        else
        {
            if (node.getData() < data)
                node.right = insert(node.right, data);
            else
                node.left = insert(node.left, data);
        }
        return node;
    }
    /* Function to count number of nodes */
    public int countNodes()
    {
        return countNodes(root);
    }
    /* Function to count number of nodes recursively */
    private int countNodes(BTNode r)
    {
        if (r == null)
            return 0;
        else
        {
            int l = 1;
            l += countNodes(r.getLeft());
            l += countNodes(r.getRight());
            return l;
        }
    }
    /* Function to search for an element */
    public boolean search(int val)
    {
        return search(root, val);
    }
    /* Function to search for an element recursively */
    private boolean search(BTNode r, int val)
    {
        if (r.getData() == val)
            return true;
        if (r.getLeft() != null)
            if (search(r.getLeft(), val))
                return true;
        if (r.getRight() != null)
            if (search(r.getRight(), val))
                return true;
        return false;
    }
    /* Function for inorder traversal */
    public void inorder()
    {
        inorder(root);
    }
    private void inorder(BTNode r)
    {
        if (r != null)
        {
            inorder(r.getLeft());
            System.out.print(r.getData() +" ");
            inorder(r.getRight());
        }
    }
    /* Function for preorder traversal */
    public void preorder()
    {
        preorder(root);
    }
    private void preorder(BTNode r)
    {
        if (r != null)
        {
            System.out.print(r.getData() +" ");
            preorder(r.getLeft());
            preorder(r.getRight());
        }
    }
    /* Function for postorder traversal */
    public void postorder()
    {
        postorder(root);
    }
    private void postorder(BTNode r)
    {
        if (r != null)
        {
            postorder(r.getLeft());
            postorder(r.getRight());
            System.out.print(r.getData() +" ");
        }
    }
}

/* Class BinaryTree */
public class Solution
{
    public static void main(String[] args)
    {
        Scanner scan = new Scanner(System.in);
        /* Creating object of BT */
        BT bt = new BT();
        /*  Perform tree operations  */
        //System.out.println("Binary Tree Test\n");


        int n=scan.nextInt();
        for(int i=1;i<=n;i++)
            bt1.insert( scan.nextInt() );


        bt1.inorder();
        System.out.println();

        bt1.preorder();
        System.out.println();
        bt1.postorder();
        System.out.println(bt1.countNodes());
    }
}
