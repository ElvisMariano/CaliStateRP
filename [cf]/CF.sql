-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 10, 2020 at 01:25 AM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `essentialmode`
--

-- --------------------------------------------------------

--
-- Table structure for table `cf_properties`
--

CREATE TABLE `cf_properties` (
  `property_name` text COLLATE utf8mb4_bin NOT NULL,
  `property_owner` text COLLATE utf8mb4_bin DEFAULT NULL,
  `property_data` text COLLATE utf8mb4_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

--
-- Dumping data for table `cf_properties`
--


-- --------------------------------------------------------

--
-- Table structure for table `cf_users`
--

CREATE TABLE `cf_users` (
  `data` text COLLATE utf8mb4_bin NOT NULL,
  `identifier` text COLLATE utf8mb4_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

--
-- Dumping data for table `cf_users`
--



--
-- Indexes for dumped tables
--

--
-- Indexes for table `cf_properties`
--
ALTER TABLE `cf_properties`
  ADD UNIQUE KEY `property_name` (`property_name`) USING HASH;

--
-- Indexes for table `cf_users`
--
ALTER TABLE `cf_users`
  ADD UNIQUE KEY `data_2` (`data`,`identifier`) USING HASH,
  ADD KEY `data` (`data`(768));



/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
