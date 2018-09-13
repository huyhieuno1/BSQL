package ThuatToan;

import java.util.Scanner;

public class Bai5 {
	
	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		boolean checkSoAm = true;
		do {
			try {
				System.out.println("Nhập vào a:");
				int a = Integer.parseInt(sc.nextLine());
				if(a>0) {					
					checkSoAm = false;
				}else {
					throw new SoAmException("Không được nhập vào số âm!");
				}
				//checkSo = false;
			}catch(Exception ex) {
				System.err.println("Vui lòng nhập vào một số!");
			}
		}while(checkSoAm);
	}

}
