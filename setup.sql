-- Recycling market tables
CREATE TABLE IF NOT EXISTS `recycle_market` (
  `item` varchar(64) NOT NULL,
  `supply` int NOT NULL DEFAULT 0,
  `demand` int NOT NULL DEFAULT 0,
  `buy_price` decimal(10,2) NOT NULL DEFAULT 1.00,
  `sell_price` decimal(10,2) NOT NULL DEFAULT 1.00,
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`item`)
);

CREATE TABLE IF NOT EXISTS `recycle_market_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item` varchar(64) NOT NULL,
  `buy_price` decimal(10,2) NOT NULL,
  `sell_price` decimal(10,2) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);
