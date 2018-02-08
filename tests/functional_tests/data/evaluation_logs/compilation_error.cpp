#include <cmath>
#include <cstdio>
#include <vector>
#include <iostream>
#include <algorithm>
// This file should give compilation error greater than 25 lines.
//using namespace std;

struct node{
    int data;
    node *left;
    node * right;
};

void insert(node *root, node *new_node) {
   if (new_node->data <= root->data) {
      if (root->left == NULL)
         root->left = new_node;
      else
         insert(root->left, new_node);
   }

   if (new_node->data > root->data) {
      if (root->right == NULL)
         root->right = new_node;
      else
         insert(root->right, new_node);
   }
}

void inOrder(node *root) {
    if(root->left != NULL){
        inOrder(root->left);

    }
    cout << root->data << " ";
    if(root->right != NULL){
        inOrder(root->right);

    }

}

void preOrder(node *root) {
    cout << root->data << " ";
    if(root->left != NULL){
        preOrder(root->left);
    }
    if(root->right != NULL)
        preOrder(root->right);
}

void postOrder(node *root) {
    if(root->left != NULL){
        postOrder(root->left);

    }
    if(root->right != NULL){
        postOrder(root->right);
    }
    cout << root->data << " ";
}

int main() {
    int n;
    cin >> n;
    int arr[n];
    for(int i=0 ; i<n ; i++){
        cin >> arr[i];
    }
    node * root;
    root=(node*)malloc(sizeof(node));

        root->data=arr[0];
        root->left=NULL;
        root->right=NULL;
    node *nod;
    nod=root;
    int i=1;
    while(i<n){
    	node *tmp;
    	tmp=(node*)malloc(sizeof(node*));
    	tmp->data=arr[i];
    	tmp->left=NULL;
    	tmp->right=NULL;
        insert(root,tmp);
        i++;
    }


    inOrder(root);
    cout << "\n";
    preOrder(root);
    cout << "\n";
    postOrder(root);
    return 0;
}
