<!DOCTYPE html>
<html>

<head>
    <title>System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f2f2f2;
            margin: 0;
            padding: 0;
        }

        .navbar {
            background-color: #ff3d3d;
            color: #fff;
            text-align: center;
            padding: 20px;
        }

        .navbar-brand {
            color: #fff;
            font-size: 24px;
            text-decoration: none;
        }

        .navbar-burger {
            display: none;
        }

        .navbar-menu-link {
            color: #fff;
            text-decoration: none;
            font-size: 18px;
            margin-right: 20px;
        }

        .container {
            max-width: 1250px;
            margin: 0 auto;
            padding: 20px;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
            border-radius: 10px;
        }

        h1 {
            color: #333;
            text-align: center;
            margin-bottom: 20px;
        }

        h2 {
            color: #2463eb;
        }

        .text-main-content {
            font-size: 18px;
            line-height: 1.6;
            color: #555;
        }

        .text-blue {
            color: #2463eb;
        }

        img {
            max-width: 100%;
            height: auto;
            display: block;
            margin: 0 auto;
        }

        .image-container {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .image-container img {
            max-width: 200px; /* Adjust the size as needed */
            height: auto;
            margin: 0 10px; /* Add some margin between the images 
            <a href="#" class="navbar-menu-link">Home</a>
            <a href="#" class="navbar-menu-link">Credits</a>   */
        }

        .img-container {
            max-width: 50px; /* Adjust the size as needed */
            height: auto;
            margin: 0 10px; 
        }

.image-bullet-list {
    list-style-type: none;
    padding-left: 0;
}

.image-bullet-list li.image-bullet {
    padding-left: 30px;
    background-repeat: no-repeat;
    background-position: left center;
    background-size: 20px auto; /* Adjust the size as needed */
    line-height: 1.6;
    margin-bottom: 10px;
}

.image-bullet {
    background-image: url('storage/images/setting.png'); /* Replace with your image URL */
}


    </style>
</head>

<body id="i09beg">
    <div class="navbar">
        <a href="#" class="navbar-brand">Online Document Requisition</a>
        <div class="navbar-burger">
            <div class="navbar-burger-line"></div>
            <div class="navbar-burger-line"></div>
            <div class="navbar-burger-line"></div>
        </div>
        <div class="navbar-items">
            
            <a href="#" class="navbar-menu-link">About</a>
            
        </div>
    </div>

    <div class="container">

        <h2>About the System</h2>
        <h1>Online Document Requisition</h1>
        <div class="text-main-content">Our Online Document Requisition with Chatbot is a solution to help
            citizens in Central Bicutan where they can inquire document requests through our chatbot, with management from
            the barangay staff to handle the requests. Using advanced technologies such as Flutter, machine learning, and
            data analytics, this system is designed to help local authorities for managing document requests in the barangay.</div>

        <h2>Key Capabilities</h2>
<ul class="image-bullet-list">
    <li class="image-bullet" style="background-image: url('storage/images/setting.png');">Document Requisition through our chatbot.</li>
    <li class="image-bullet" style="background-image: url('storage/images/setting.png');">Secure and user-friendly platform.</li>
    <li class="image-bullet" style="background-image: url('storage/images/setting.png');">Assistance and support</li>
</ul>


        <h2>Note</h2>
        <h4>BSCS A2020</h4>
        <div class="text-main-content">This system is in partial fulfillment of the requirements for a Thesis in Taguig City University. It provides a practical and user-friendly platform and is the product of extensive research and analysis needed for successful completion. Please note that the write-up is yet to be defended and is still in the works.</div>

        <div class="image-container">
            <img src="storage/images/tcu.png" alt="Taguig City University" />
            <img src="storage/images/cict.png" alt="CICT" />
        </div>
    </div>

    <div class="text-blue" style="text-align: center; padding: 10px;">Copyright © 2023 A2020</div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const burger = document.querySelector(".navbar-burger");
            const menu = document.querySelector(".navbar-items");

            burger.addEventListener("click", function() {
                menu.classList.toggle("active");
            });
        });
    </script>
</body>

</html>
