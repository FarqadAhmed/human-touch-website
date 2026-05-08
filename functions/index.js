const functions = require("firebase-functions");
const axios = require("axios");

exports.searchAccessiblePlaces = functions.https.onRequest(async (req, res) => {
  try {
    const { query, userLat, userLng } = req.body;

    if (!query || !userLat || !userLng) {
      return res.status(400).json({
        error: "Missing required fields",
      });
    }

    const apiKey = "YOUR_GOOGLE_MAPS_API_KEY";

    const placesUrl =
      `https://maps.googleapis.com/maps/api/place/nearbysearch/json` +
      `?location=${userLat},${userLng}` +
      `&radius=3000` +
      `&keyword=${encodeURIComponent(query)}` +
      `&key=${apiKey}`;

    const response = await axios.get(placesUrl);

    const results = (response.data.results || []).map((place) => {
      const lat = place.geometry.location.lat;
      const lng = place.geometry.location.lng;

      return {
        id: place.place_id,
        name: place.name,
        category: place.types?.[0] || "Place",
        lat: lat,
        lng: lng,
        distanceKm: calculateDistance(userLat, userLng, lat, lng),
        wheelchairEntrance: true,
        accessibleParking: false,
        accessibleRestroom: false,
        accessibleSeating: false,
        note: "Accessibility details may need confirmation.",
        mapsUri:
          `https://www.google.com/maps/search/?api=1&query=${lat},${lng}`,
      };
    });

    return res.status(200).json({ results });
  } catch (error) {
    return res.status(500).json({
      error: "Search failed",
      details: error.message,
    });
  }
});

function calculateDistance(lat1, lng1, lat2, lng2) {
  const R = 6371;

  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLng / 2) *
      Math.sin(dLng / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return Number((R * c).toFixed(2));
}

function toRad(value) {
  return (value * Math.PI) / 180;
}