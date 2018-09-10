use BANHANG
go

-- 1.	Hãy cho biết có những khách hàng nào lại chính là đối tác cung cấp hàng của công ty (tức là có cùng tên giao dịch). 

SELECT * FROM khachhang
INNER JOIN nhacungcap
ON khachhang.tengiaodich = nhacungcap.tengiaodich

-- 2.	Những đơn đặt hàng nào yêu cầu giao hàng ngay tại cty đặt hàng và những đơn đó là của công ty nào? 

SELECT * FROM dondathang
INNER JOIN khachhang ON khachhang.diachi = dondathang.noigiaohang

-- 3.	Những mặt hàng nào chưa từng được khách hàng đặt mua?

SELECT * FROM mathang
WHERE mahang NOT IN (SELECT mahang FROM chitietdathang)

-- 4.	Những nhân viên nào của công ty chưa từng lập bất kỳ một hoá đơn đặt hàng nào? 

SELECT * FROM nhanvien
WHERE manhanvien NOT IN (SELECT manhanvien FROM dondathang)

-- 5.	Trong năm 2003, những mặt hàng nào chỉ được đặt mua đúng một lần

SELECT chitietdathang.mahang FROM dondathang
INNER JOIN chitietdathang ON dondathang.sohoadon = chitietdathang.sohoadon
WHERE DATEPART(year,ngaydathang) = 2013 
AND chitietdathang.mahang IN 
(
	SELECT mahang FROM chitietdathang GROUP BY mahang HAVING COUNT(mahang) = 1
)

-- 6.	Hãy cho biết mỗi một khách hàng đã phải bỏ ra bao nhiêu tiền để đặt mua hàng của công ty? 

SELECT khachhang.makhachhang,tencongty,tengiaodich,
       SUM (soluong*giaban-soluong*giaban*mucgiamgia/100)AS giatien
FROM khachhang INNER JOIN dondathang
ON khachhang.makhachhang=dondathang.makhachhang
INNER JOIN chitietdathang
ON dondathang.sohoadon=chitietdathang.sohoadon
GROUP BY khachhang.makhachhang,tencongty,tengiaodich


-- 7.	Mỗi một nhân viên của công ty đã lập bao nhiêu đơn đặt hàng (nếu nhân viên chưa hề lập một hoá đơn nào thì cho kết quả là 0)

SELECT nhanvien.manhanvien,ho,ten,COUNT(sohoadon) AS tongsohoadon
FROM nhanvien LEFT OUTER JOIN dondathang
       ON nhanvien.manhanvien=dondathang.manhanvien
GROUP BY nhanvien.manhanvien,ho,ten 


-- 8.	Cho biết tổng số tiền hàng mà cửa hàng thu được trong mỗi tháng của năm 2003 (thời được gian tính theo ngày đặt hàng).

SELECT MONTH(ngaydathang)AS thang,
         SUM (soluong*giaban-soluong*giaban*mucgiamgia/100)AS sotien
FROM dondathang INNER JOIN chitietdathang
       ON dondathang.sohoadon=chitietdathang.sohoadon
WHERE YEAR(ngaydathang)=2003
GROUP BY month (ngaydathang)
 
-- 9.	Hãy cho biết tổng số lượng hàng của mỗi mặt hàng mà cty đã có (tổng số lượng hàng hiện có và đã bán). 

SELECT mathang.mahang,tenhang,mathang.soluong+
         CASE
            WHEN SUM(chitietdathang.soluong) IS NULL THEN 0
            ELSE SUM(chitietdathang.soluong)
            END AS tongsoluong
FROM mathang LEFT OUTER JOIN chitietdathang
ON mathang.mahang=chitietdathang.mahang
GROUP BY mathang.mahang, tenhang, mathang.soluong

-- 10.	Nhân viên nào của cty bán được số lượng hàng nhiều nhất và số lượng hàng bán được của nhân viên này là bao nhiêu?

SELECT nhanvien.manhanvien, ho,ten,SUM(soluong)as tongsoluong
FROM (nhanvien INNER JOIN dondathang
        ON nhanvien.manhanvien=dondathang.manhanvien)
        INNER JOIN chitietdathang
        ON dondathang.sohoadon=chitietdathang.sohoadon
GROUP BY nhanvien.manhanvien,ho,ten
HAVING SUM(soluong)>=ALL
         (SELECT sum(soluong)
            FROM (nhanvien INNER JOIN dondathang
                    ON nhanvien.manhanvien=dondathang.manhanvien)
                    INNER JOIN chitietdathang ON
                    dondathang.sohoadon=chitietdathang.sohoadon
            GROUP BY nhanvien.manhanvien,ho,ten)

-- 11.	Mỗi một đơn đặt hàng đặt mua những mặt hàng nào và tổng số tiền mà mỗi đơn đặt hàng phải trả là bao nhiêu?

SELECT A.sohoadon,B.mahang,tenhang,
         B.soluong*giaban-B.soluong*giaban*mucgiamgia/100
FROM (dondathang AS A INNER JOIN chitietdathang AS B
        ON A.sohoadon=B.sohoadon)
        INNER JOIN mathang AS C ON B.mathang=C.mathang
ORDER BY A.sohoadon
COMPUTE SUM(B.soluong*giaban-B.soluong*giaban*mucgiamgia/100)
            BY A.sohoadon
 
-- 12.	Hãy cho biết mỗi một loại hàng bao gồm những mặt hàng nào, tổng số lượng hàng của mỗi loại và tổng số lượng của tất cả các mặt hàng hiện có trong công ty là bao nhiêu? 

SELECT loaihang.maloaihang,tenloaihang,mahang,tenhang,soluong
FROM loaihang INNER JOIN mathang
       ON loaihang.maloaihang=mathang.maloaihang
ORDER BY loaihang.maloaihang
COMPUTE SUM(soluong)BY loaihang.maloaihang
COMPUTE SUM(soluong)

-- 13.	Thống kê xem trong năm 2003, mỗi một mặt hàng trong mỗi tháng và trong cả năm bán được với số lượng bao nhiêu.

SELECT B.mahang,tenhang,
         SUM(CASE MONTH(ngaydathang)WHEN 1 THEN B.soluong
               ELSE 0 END) AS thang1,
       SUM(CASE MONTH(ngaydathang)WHEN 2 THEN B.soluong
               ELSE 0 END) AS thang2,
         SUM(CASE MONTH(ngaydathang)WHEN 3 THEN B.soluong
               ELSE 0 END) AS thang3,
         SUM(CASE MONTH(ngaydathang)WHEN 4 THEN B.soluong
               ELSE 0 END) AS thang4,
       SUM(CASE MONTH(ngaydathang)WHEN 5 THEN B.soluong
               ELSE 0 END) AS thang5,
       SUM(CASE MONTH(ngaydathang)WHEN 6 THEN B.soluong
               ELSE 0 END) AS thang6,
       SUM(CASE MONTH(ngaydathang)WHEN 7 THEN B.soluong
               ELSE 0 END) AS thang7,
       SUM(CASE MONTH(ngaydathang)WHEN 8 THEN B.soluong
               ELSE 0 END) AS thang8,
       SUM(CASE MONTH(ngaydathang)WHEN 9 THEN B.soluong
               ELSE 0 END) AS thang9,
       SUM(CASE MONTH(ngaydathang)WHEN 10 THEN B.soluong
               ELSE 0 END) AS thang10,
       SUM(CASE MONTH(ngaydathang)WHEN 11 THEN B.soluong
               ELSE 0 END) AS thang11,
       SUM(CASE MONTH(ngaydathang)WHEN 12 THEN B.soluong
               ELSE 0 END) AS thang12,
       SUM (B.soluong) AS canam
FROM (dondathang AS A INNER JOIN chitietdathang AS B
        ON A.sohoadon=B.sohoadon)
        INNER JOIN mathang AS C ON B.mahang=C.mahang
WHERE YEAR(ngaydathang)=2003
GROUP BY B.mathang,tenhang

-- 14.	Cập nhật lại giá trị NGAYCHUYENHANG của những bản ghi có giá trị NGAYCHUYENHANG chưa xác định (NULL) trong bảng DONDATHANG bằng với giá trị của trường NGAYDATHANG.

UPDATE dondathang
SET ngaychuyenhang=ngaydathang
WHERE ngaychuyenhang IS NULL

-- 15.	Cập nhật giá trị của trường NOIGIAOHANG trong bảng DONDATHANG bằng địa chỉ của khách hàng đối với những đơn đặt hàng chưa xác định được nơi giao hàng (có giá trị trường NOIGIAOHANG bằng NULL)

UPDATE dondathang
SET noigiaohang=diachi
FROM khachhang
WHERE dondathang.makhachhang=khachhang.makhachhang
      AND noigiaohang IS NULL

-- 16.	Cập nhật lại dữ liệu trong bảng KHACHHANG sao cho nếu tên công ty và tên giao dịch của khách hàng trùng với tên công ty và tên giao dịch của một nhà cung cấp nào đó thì địa chỉ, điện thoại, fax và email phải giống nhau.

UPDATE khachhang
SET khachhang.diachi=nhacungcap.diachi,
      khachhang.dienthoai=nhacungcap.dienthoai,
      khachhang.fax=nhacungcap.fax,
      khachhang.email=nhacungcap.email
FROM nhacungcap
WHERE khachhang.tencongty=nhacungcap.tencongty
        AND khachhang.tengiaodich=nhacungcap.tengiaodich

-- 17.	Tăng lương lên gấp rưỡi cho những nhân viên bán được số lượng hàng nhiều hơn 100 trong năm 2003 

UPDATE nhanvien
SET luongcoban=luongcoban*1.5
WHERE manhanvien=
        (SELECT manhanvien
         FROM dondathang INNER JOIN chitietdathang
       ON dondathang.sohoadon=chitietdathang.sohoadon
       WHERE manhanvien=nhanvien.manhanvien
       GROUP BY manhanvien
       HAVING  SUM(soluong)>100 AND YEAR (ngaygiaohang)=2003)

-- 18.	Tăng phụ cấp lên bằng 50% lương cho những nhân viên bán được hàng nhiều nhất.

UPDATE nhanvien
SET phucap=luongcoban/2
WHERE manhanvien IN
                  (select manhanvien
                  from dondathang, chitietdathang
                  where dondathang.sohoadon=chitietdathang.sohoadon
                  group by manhanvien
                  having sum (soluong)>= all
(select sum (soluong)from dondathang,chitietdathang
                  where dondathang.sohoadon=chitietdathang.sohoadon
                                          group by manhanvien))

-- 19.	Giảm 25% lương của những nhân viên trong năm 2003 ko lập được bất kỳ đơn đặt hàng nào

UPDATE nhanvien
SET luongcoban= luongcoban-luongcoban*0.25
WHERE NOT EXISTS (select manhanvien from dondathang where dondathang.manhanvien=nhanvien.manhanvien)

-- 20.	Giả sử trong bảng DONDATHANG có them trường SOTIEN cho biết số tiền mà khách hàng phải trả trong mỗi dơnđặt hàng. Hãy tính giá trị cho trường này.

UPDATE dondathang
SET sotien = (select SUM(soluong*giaban- soluong*giaban*mucgiamgia)
                        from chitietdathang where dondathang.sohoadon=chitietdathang.sohoadon)

-- 21.	Xoá khỏi bảng MATHANG những mặt hàng có số lượng bằng 0 và không được đặt mua trong bất kỳ đơn đặt hàng nào.

DELETE FROM mathang
            WHERE NOT EXISTS (select mahang from chitietdathang where chitietdathang.mahang=mathang.mahang) AND mathang.soluong =0


----------------------------------------- BT2--------------------------------------

-- 11. Hãy cho biết số tiền lương mà công ty phải trả cho mỗi nhân viên là bao nhiêu (lương = lương cơ bn + phụ cấp)

SELECT manhanvien,ho,ten,
luongcoban + CASE
WHEN phucap IS NULL THEN 0
ELSE phucap
END AS luong
FROM nhanvien

-- 12. Trong đơn đặt hàng số 3 đặt mua nhưng mặt hàng nào và số tiền mà khách hàngphải trả cho mỗi mặt hàng là bao nhiêu (số tiền phải trả cho mõi mặt hang tính theo công thức

SELECT a.mahang,tenhang,
a.soluong*giaban*(1-mucgiamgia/100) AS sotien
FROM chitietdathang AS a INNER JOIN mathang AS b
ON a.mahang=b.mahang

-- 19. Những nhân viên nào của công ty có lương cơ bản cao nhất?

SELECT manhanvien,ho,ten,luongcoban
FROM nhanvien
WHERE luongcoban=(SELECT MAX(luongcoban) FROM nhanvien)

-- 20. Tổng số tiền mà khách hàng phải trả cho mỗi đơn đặt hàng là bao nhiêu?

SELECT dondathang.sohoadon,dondathang.makhachhang,tencongty,tengiaodich,
SUM(soluong*giaban-soluong*giaban*mucgiamgia/100)
FROM (khachhang INNER JOIN dondathang
ON khachhang.makhachhang=dondathang.makhachhang)
INNER JOIN chitietdathang
ON dondathang.sohoadon=chitietdathang.sohoadon
GROUP BY dondathang.makhachhang,tencongty,tengiaodich,dondathang.sohoadon

-- 21. Trong nm 2003, những mặt hàng nào chỉ được đặt mua đúng một lần.

SELECT mathang.mahang,tenhang
FROM (mathang INNER JOIN chitietdathang
ON mathang.mahang=chitietdathang.mahang)
iNNER JOIN dondathang
ON chitietdathang.sohoadon=dondathang.sohoadon
WHERE YEAR(ngaydathang)=2003
GROUP BY mathang.mahang,tenhang
HAVING COUNT(chitietdathang.mahang)=1

-- 22. Hãy cho biết mỗi một khách hàng đã phải bỏ ra bao nhiêu tiền để đặt mua hàng Của công ty?

SELECT khachhang.makhachhang,tencongty,tengiaodich,
SUM(soluong*giaban-soluong*giaban*mucgiamgia/100)
FROM (khachhang INNER JOIN dondathang
ON khachhang.makhachhang = dondathang.makhachhang)
INNER JOIN chitietdathang
ON dondathang.sohoadon=chitietdathang.sohoadon
GROUP BY khachhang.makhachhang,tencongty,tengiaodich

-- 29 Số tiền nhiều nhất mà mỗi khách hàng đã từng bỏ ra đặt hàng trong các đơn đặt hàng là bao nhiêu?

SELECT TOP 1
SUM(soluong*giaban-soluong*giaban*mucgiamgia/100)
FROM dondathang INNER JOIN chitietdathang
ON dondathang.sohoadon=chitietdathang.sohoadon
ORDER BY 1 DESC

-- 30. 30 Mỗi một đơn đặt hàng đặt mua những mặt hàng nào và tổng số tiền mà mỗi đơn Đặt hàng phải trả là bao nhiêu?

SELECT a.sohoadon,b.mahang,tenhang,
b.soluong*giaban-b.soluong*giaban*mucgiamgia/100
FROM (dondathang AS a INNER JOIN chitietdathang AS b
ON a.sohoadon = b.sohoadon)
INNER JOIN mathang AS c ON b.mahang = c.mahang
ORDER BY a.sohoadon
COMPUTE SUM(b.soluong*giabanb.
soluong*giaban*mucgiamgia/100) BY a.sohoadon

-- 31. 31 Hãy cho biết mỗi một loại hàng bao gồm những mặt hàng nào, tổng số lượnghàng của mỗi loại và tổng số lượng của tất cả các mặt hàng hiện có trong công ty là baonhiêu?

SELECT loaihang.maloaihang,tenloaihang,
mahang,tenhang,soluong
FROM loaihang INNER JOIN mathang
ON loaihang.maloaihang=mathang.maloaihang
ORDER BY loaihang.maloaihang
COMPUTE SUM(soluong) BY loaihang.maloaihang
COMPUTE SUM(soluong)

-- 41 Xoá khi bảng NHANVIEN những nhân viên đã làm việc trong công ty quá 40năm.

DELETE FROM nhanvien
WHERE DATEDIFF(YY,ngaylamviec,GETDATE())>40

-- 42 Xoá những đơn đặt hàng trước năm 2000 ra khỏi cơ sở dữ liệu.

DELETE FROM dondathang
WHERE ngaydathang<'1/1/2000'