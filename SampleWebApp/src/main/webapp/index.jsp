<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Welcome to Trippy Universe</title>
  <style>
    body {
      background-color: #7FFF00; /* Chartreuse */
      font-family: Arial, sans-serif;
    }
  </style>
</head>
<body>
  <h1>This is just me playing around with my keyboard</h1>

  <form action="profile.html" method="post">
    <p>Let us learn something about your music lifestyle</p>
    <textarea name="comments" cols="30" rows="5"></textarea>

    <p>Select your favourite genre of music</p>
    <label><input type="radio" name="genre" value="rock" checked> Rock</label><br>
    <label><input type="radio" name="genre" value="pop"> Pop</label><br>
    <label><input type="radio" name="genre" value="reggae"> Reggae</label><br>
    <label><input type="radio" name="genre" value="jazz"> Jazz</label>

    <p>Select your favourite music service</p>
    <label><input type="checkbox" name="service" value="iTunes"> iTunes</label><br>
    <label><input type="checkbox" name="service" value="Spotify"> Spotify</label><br>
    <label><input type="checkbox" name="service" value="Pandora"> Pandora</label><br>
    <label><input type="checkbox" name="service" value="FishFM"> Fish FM</label>

    <p>What device do you listen to music on</p>
    <select name="devices">
      <option value="ipod">iPod</option>
      <option value="radio">Radio</option>
      <option value="tv">TV</option>
      <option value="phone">Phone</option>
      <option value="computer">Computer</option>
      <option value="echo">Echo</option>
    </select>

    <p>Select the instruments you're capable of playing (hold CTRL to select multiple)</p>
    <select name="instruments" multiple>
      <option value="guitar">Guitar</option>
      <option value="drum">Drum</option>
      <option value="keyboard">Keyboard</option>
      <option value="shekere">Shekere</option>
      <option value="trumpet">Trumpet</option>
    </select>

    <p>Upload your song in MP3 format only</p>
    <input type="file" name="user_song" accept=".mp3,audio/mpeg"><br>
    <input type="submit" value="Upload">

    <p>Enter Your Email to subscribe to our weekly newsletter</p>
    <input type="email" name="newsletter_email" placeholder="Enter your email">
    <input type="button" value="Subscribe">

    <p>
      <label>Age: <input type="number" name="age"></label>
    </p>
    <p>Gender:
      <label><input id="female" type="radio" name="gender" value="f"> Female</label>
      <label><input id="male" type="radio" name="gender" value="m"> Male</label>
      <label><input id="other" type="radio" name="gender" value="o"> Other</label>
    </p>

    <fieldset>
      <legend><strong>Bio Data</strong></legend>
      <label>First Name: <input type="text" name="fname"></label><br><br>
      <label>Last Name: <input type="text" name="lname"></label><br><br>
      <label>D.O.B: <input type="date" name="dob"></label><br><br>

      <fieldset>
        <legend><strong>Contact Info</strong></legend>
        <label>Mobile No: <input type="tel" name="mobile"></label>
        <label>Email: <input type="email" name="contact_email"></label><br><br>
        <label>Address: <input type="text" name="address"></label>
        <label>City: <input type="text" name="city"></label><br><br>
        <label>State:
          <select name="state">
            <option value="AL">Alabama</option>
            <option value="TX">Texas</option>
            <option value="TN">Tennessee</option>
            <option value="AK">Arkansas</option>
            <option value="AZ">Arizona</option>
            <option value="LA">Louisiana</option>
          </select>
        </label>
        <label>Zip Code: <input type="text" name="zipcode"></label>
      </fieldset>
    </fieldset>

    <p><strong>Search Here</strong></p>
    <input type="search" name="search" placeholder="Enter search keyword">
    <input type="submit" value="Search">
  </form>
</body>
</html>
