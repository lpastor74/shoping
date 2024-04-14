CREATE DATABASE `cloud_demo` ;

CREATE TABLE `Product` (
  `id` int NOT NULL AUTO_INCREMENT,
  `Type` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `Stock` (
  `id` int NOT NULL AUTO_INCREMENT,
  `Qty` decimal(5,2) DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `storage_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `Stock_Product_FK` (`product_id`),
  KEY `Stock_Storage_FK` (`storage_id`),
  CONSTRAINT `Stock_Product_FK` FOREIGN KEY (`product_id`) REFERENCES `Product` (`id`),
  CONSTRAINT `Stock_Storage_FK` FOREIGN KEY (`storage_id`) REFERENCES `Storage` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=224 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `Storage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `zip` char(5) COLLATE utf8mb4_general_ci NOT NULL,
  `phone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE PROCEDURE `cloud_demo`.`orderList`(IN productID INT, IN zip CHAR(5), IN qty DECIMAL(5,2))
BEGIN
	DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE c_zip VARCHAR(5);
    DECLARE c_address VARCHAR(255);
    DECLARE c_product_name VARCHAR(255);
    DECLARE c_quantity DECIMAL(5, 2); 
    DECLARE totalQuantity DECIMAL(10, 2) DEFAULT 0.00;
	
	DECLARE orderCursor CURSOR FOR
         select s.Qty, s2.zip, s2.Address,p.Name from 
		 Stock s inner join Product p on s.product_id = p.id inner JOIN Storage s2 on s.storage_id = s2.id 
		 where p.id = productID and s2.zip like zip
		 ORDER by s.Qty DESC, s2.zip;
		
    -- Declare handler for cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
   
   	-- Temporary table to store product quantities
    CREATE TEMPORARY TABLE IF NOT EXISTS tempProductQuantityPerZip ( 
        t_prod_quantity DECIMAL(5,2),
        t_zip VARCHAR(5),
        t_address VARCHAR(255),
        t_product_name VARCHAR(255)
    );	
   
    Delete FROM tempProductQuantityPerZip;
    set totalQuantity = 0;
   
    -- Open cursor
    OPEN orderCursor; 
   
   -- Start iterating over the returned list
    read_loop: LOOP
        -- Fetch data from cursor into variables
        FETCH orderCursor INTO c_quantity,c_zip,c_address,c_product_name;
        
        -- Check if cursor has reached the end of the result set
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        IF totalQuantity < qty then
         INSERT into tempProductQuantityPerZip(t_prod_quantity,t_zip,t_address,t_product_name) VALUES (c_quantity,c_zip,c_address,c_product_name);
        END IF;
       
       SET totalQuantity = totalQuantity + c_quantity;
        
     END LOOP read_loop;
    
    -- Close cursor
    CLOSE orderCursor;
   
    Select * from tempProductQuantityPerZip;
END;