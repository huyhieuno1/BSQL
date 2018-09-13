package ThuatToan;

import java.util.Scanner;

public class test {
		
		public void input(){
			Scanner input = new Scanner(System.in);
			boolean check = true;
			do{
			 try {
			    System.out.println(" Nhap vao a : ");
		    	int  a = Integer.parseInt(input.nextLine());
			    System.out.println(" Nhap vao b :");
			    int b = Integer.parseInt(input.nextLine());
			    if (a != 0){
			    	System.out.println(" Nghiem Cua Phuong Trinh x= " + (-b/a));
			    	check = false;
			    	//throw new MyException( " Vui long nhap a khac 0!");	
			    }else {	
			    	
			    }
			 }  catch (NumberFormatException e) {
				System.err.println(" Vui long nhap vao mot so :");
		    }catch (Exception e){
			System.out.println( e.getMessage());
		}
		}while (check);
			
		}
		public static void main(String[] args){
			test t = new test();
			t.input();
			
		}
	

}
