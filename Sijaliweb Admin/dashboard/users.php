<?php
// Mulai sesi
// session_start();

// // Periksa apakah variabel sesi 'user_id' sudah diatur
// if (!isset($_SESSION['user_id'])) {
//     // Jika tidak, redirect ke halaman login
//     header('Location: ../sign-in/index.php'); // Gantilah dengan path yang benar
//     exit();
// }

// // Jika user_id sudah diatur, Anda dapat mengakses nilai user_id dari $_SESSION['user_id']
// $user_id = $_SESSION['user_id'];

// Selanjutnya, Anda dapat melakukan apa pun yang perlu dilakukan di halaman users.php

?>

<?php
// Sambungkan ke database
include '..\conn.php';

// Ambil data dari tabel users
$query = "SELECT id, nama, username, role FROM users";
$result = $conn->query($query);

// Tutup koneksi
$conn->close();
?>

<!doctype html>
<html lang="en" data-bs-theme="auto">

<head>
  <script src="../assets/js/color-modes.js"></script>

  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="">
  <meta name="author" content="Hamdani">
  <meta name="generator" content="Hugo 0.118.2">
  <title>Dashboard</title>
  <link rel="shortcut icon" href="../assets/brand/logo.png" type="image/x-icon">

  <link rel="canonical" href="https://getbootstrap.com/docs/5.3/examples/dashboard/">



  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@docsearch/css@3">

  <!-- Fungsi JavaScript untuk konfirmasi penghapusan -->
  <script>
    function confirmDelete(userId) {
      var confirmation = confirm("Apakah Anda yakin ingin menghapus data?");

      if (confirmation) {
        // Jika dikonfirmasi, arahkan ke skrip penghapusan (misal: delete_user.php?id=userId)
        window.location.href = 'delete_user.php?id=' + userId;
      }
    }
  </script>

  <link href="../assets/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    .bd-placeholder-img {
      font-size: 1.125rem;
      text-anchor: middle;
      -webkit-user-select: none;
      -moz-user-select: none;
      user-select: none;
    }





    @media (min-width: 768px) {
      .bd-placeholder-img-lg {
        font-size: 3.5rem;
      }
    }

    .b-example-divider {
      width: 100%;
      height: 3rem;
      background-color: rgba(0, 0, 0, .1);
      border: solid rgba(0, 0, 0, .15);
      border-width: 1px 0;
      box-shadow: inset 0 .5em 1.5em rgba(0, 0, 0, .1), inset 0 .125em .5em rgba(0, 0, 0, .15);
    }

    .b-example-vr {
      flex-shrink: 0;
      width: 1.5rem;
      height: 100vh;
    }

    .bi {
      vertical-align: -.125em;
      fill: currentColor;
    }

    .nav-scroller {
      position: relative;
      z-index: 2;
      height: 2.75rem;
      overflow-y: hidden;
    }

    .nav-scroller .nav {
      display: flex;
      flex-wrap: nowrap;
      padding-bottom: 1rem;
      margin-top: -1px;
      overflow-x: auto;
      text-align: center;
      white-space: nowrap;
      -webkit-overflow-scrolling: touch;
    }

    .btn-bd-primary {
      --bd-violet-bg: #712cf9;
      --bd-violet-rgb: 112.520718, 44.062154, 249.437846;

      --bs-btn-font-weight: 600;
      --bs-btn-color: var(--bs-white);
      --bs-btn-bg: var(--bd-violet-bg);
      --bs-btn-border-color: var(--bd-violet-bg);
      --bs-btn-hover-color: var(--bs-white);
      --bs-btn-hover-bg: #6528e0;
      --bs-btn-hover-border-color: #6528e0;
      --bs-btn-focus-shadow-rgb: var(--bd-violet-rgb);
      --bs-btn-active-color: var(--bs-btn-hover-color);
      --bs-btn-active-bg: #5a23c8;
      --bs-btn-active-border-color: #5a23c8;
    }

    .bd-mode-toggle {
      z-index: 1500;
    }

    .bd-mode-toggle .dropdown-menu .active .bi {
      display: block !important;
    }
  </style>


  <!-- Custom styles for this template -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.min.css" rel="stylesheet">
  <!-- Custom styles for this template -->
  <link href="dashboard.css" rel="stylesheet">
</head>


<body>
  <?php
    include 'toggle.php';
include 'svg.php';
?>


  <header class="navbar sticky-top bg-dark flex-md-nowrap p-0 shadow" data-bs-theme="dark">
    <a class="navbar-brand col-md-3 col-lg-2 me-0 px-3 fs-6 text-white" href="users.php"><h4 style="text-align: center;">Si Jali - KBLI</h4></a>
    <ul class="navbar-nav flex-row d-md-none">
      <li class="nav-item text-nowrap">
        <button class="nav-link px-3 text-white" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSearch"
          aria-controls="navbarSearch" aria-expanded="false" aria-label="Toggle search">
          <svg class="bi">
            <use xlink:href="#search" />
          </svg>
        </button>
      </li>
      <li class="nav-item text-nowrap">
        <button class="nav-link px-3 text-white" type="button" data-bs-toggle="offcanvas" data-bs-target="#sidebarMenu"
          aria-controls="sidebarMenu" aria-expanded="false" aria-label="Toggle navigation">
          <svg class="bi">
            <use xlink:href="#list" />
          </svg>
        </button>
      </li>
    </ul>

    <div id="navbarSearch" class="navbar-search w-100 collapse">
      <input class="form-control w-100 rounded-0 border-0" type="text" placeholder="Search" aria-label="Search">
    </div>
  </header>

  <div class="container-fluid">
    <div class="row">
      <?php
      include 'sidebar.php';
?>

      <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
        <div
          class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
          <h1 class="h2">Daftar Users</h1>
          <div class="btn-toolbar mb-2 mb-md-0">
            <div class="btn-group me-2">
              <form id="myForm" action="import.php" method="post" enctype="multipart/form-data">
                <input type="file" name="file" id="fileInput">

                <button type="submit" class="btn btn-sm btn-outline-secondary">Import</button>


              </form>

            </div>
            <div class="btn-group me-2">

              <button type="button" class="btn btn-sm btn-outline-secondary" onclick="exportData()">Export</button>
              <!-- <button id="downloadTemplate" type="button" class="btn btn-sm btn-outline-secondary">Add User</button> -->
              <button id="downloadTemplate" type="button" class="btn btn-sm btn-outline-secondary">Template</button>
              <button id="addUser" type="button" class="btn btn-sm btn-outline-secondary">Add User</button>
            </div>
          </div>
        </div>

        <div class="table-responsive small">
          <table class="table table-striped table-sm">
            <thead>
              <tr>
                <th scope="col">No</th>
                <th scope="col">Nama Lengkap</th>
                <th scope="col">Username</th>
                <th scope="col">Role</th>
                <th scope="col">Action</th>
              </tr>
            </thead>
            <tbody>
              <?php
// Periksa apakah hasil query mengandung data
if ($result->num_rows > 0) {
    // Output data ke dalam baris tabel
    while ($row = $result->fetch_assoc()) {
        echo "<tr>";
        echo "<td>" . $row["id"] . "</td>";
        echo "<td>" . $row["nama"] . "</td>";
        echo "<td>" . $row["username"] . "</td>";
        echo "<td>" . $row["role"] . "</td>";
        //echo '<td><a href="edit_user.php?id=' . $row["id"] . '">Edit</a> | <a href="delete_user.php?id=' . $row["id"] . '">Delete</a></td>';
        //echo '<td><a href="edit_user.php?id=' . $row["id"] . '"><i class="bi bi-pencil"></i></a> | <a href="delete_user.php?id=' . $row["id"] . '"><i class="bi bi-trash"></i></a></td>';
        echo '<td><a href="edit_user.php?id=' . $row["id"] . '"><i class="bi bi-pencil"></i></a> | <a href="#" onclick="confirmDelete(' . $row["id"] . ')"><i class="bi bi-trash"></i></a></td>';

        echo "</tr>";
    }
} else {
    // Jika tidak ada data
    echo "<tr><td colspan='5'>Tidak ada data pengguna</td></tr>";
}
?>
            </tbody>
          </table>

        </div>




      </main>
    </div>
  </div>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      var downloadTemplateBtn = document.getElementById('downloadTemplate');
      if (downloadTemplateBtn) {
        downloadTemplateBtn.addEventListener('click', function() {
          // Ganti URL berikut dengan URL yang benar sesuai dengan struktur folder Anda
          var templateUrl = '../template/template.xlsx';

          // Membuat elemen anchor untuk menginisiasi pengunduhan
          var downloadLink = document.createElement('a');
          downloadLink.href = templateUrl;
          downloadLink.download = 'template.xlsx'; // Nama file yang akan diunduh

          // Menambahkan elemen ke dalam dokumen dan mengkliknya untuk memulai pengunduhan
          document.body.appendChild(downloadLink);
          downloadLink.click();
          document.body.removeChild(downloadLink);
        });
      }
    });
  </script>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      var signOutLink = document.getElementById('logoutLink');
      if (signOutLink) {
        signOutLink.addEventListener('click', function(event) {
          event.preventDefault();
          var confirmLogout = window.confirm('Apakah yakin ingin keluar?');
          if (confirmLogout) {
            window.location.href = '../sign-in/index.php'; // Redirect to index.php on logout
          }
          // If 'Cancel' is clicked, the pop-up will be closed, and no further action is needed.
        });
      }
    });
  </script>


  <!-- Di bagian head atau sebelum akhir body -->


  <script>
    function exportData() {
      window.location.href = 'export.php';
    }
  </script>




  <script src="../assets/dist/js/bootstrap.bundle.min.js"></script>

  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.3.2/dist/chart.umd.js"
    integrity="sha384-eI7PSr3L1XLISH8JdDII5YN/njoSsxfbrkCTnJrzXt+ENP5MOVBxD+l6sEG4zoLp" crossorigin="anonymous">
  </script>
  <script src="dashboard.js"></script>
  <script>
    // JavaScript to handle the click event on the "Add User" button
    document.getElementById('addUser').addEventListener('click', function() {
      // Redirect to the "add_user.php" page (change the URL as needed)
      window.location.href = 'add_user.php';
    });
  </script>



</body>


</html>