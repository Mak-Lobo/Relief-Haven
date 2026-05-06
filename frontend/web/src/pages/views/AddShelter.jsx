import {useState} from "react";
import {useNavigate} from "react-router-dom";
import {MapContainer, TileLayer, Marker, useMapEvents} from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";
import common from "../../styles/views-common.module.css";
import styles from "../../styles/shelter-form.module.css";
import {useAuth} from "../../context/AuthContext.jsx";
import {createShelter} from "../../services/shelter/shelterService";

// Fix for default markers in react-leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png",
    iconUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png",
    shadowUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png",
});

// Component for handling map clicks
const LocationSelector = ({onLocationSelect, initialPosition}) => {
    const [position, setPosition] = useState(initialPosition);

    useMapEvents({
        click: (e) => {
            const {lat, lng} = e.latlng;
            setPosition([lat, lng]);
            onLocationSelect(lat, lng);
        },
    });

    return position ? <Marker position={position}/> : null;
};

const AddShelter = () => {
    const {profile, user} = useAuth();
    const navigate = useNavigate();
    const [showMap, setShowMap] = useState(false);
    const [selectedLocation, setSelectedLocation] = useState("");
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [success, setSuccess] = useState(false);
    const [formData, setFormData] = useState({
        name: "",
        county: "",
        location: "",
        subcounty: "",
        occupants: "",
        capacity: ""
    });

    const handleLocationClick = () => {
        if (profile?.role_user === 'command') {
            setShowMap(true);
        }
    };

    const handleLocationSelect = (lat, lng) => {
        // Convert to WKT format: POINT(lng lat)
        const wktLocation = `POINT(${lng} ${lat})`;
        setSelectedLocation(wktLocation);
        setFormData(prev => ({...prev, location: wktLocation}));
        setShowMap(false);
    };

    const handleInputChange = (e) => {
        const {name, value} = e.target;
        setFormData(prev => ({...prev, [name]: value}));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        
        if (!user?.token || !profile) {
            setError("Authentication failed. Please log in again.");
            return;
        }

        if (!formData.location) {
            setError("Please select a location on the map.");
            return;
        }

        try {
            setLoading(true);
            setError(null);

            const shelterData = {
                name: formData.name,
                county: formData.county,
                location: formData.location,
                subcounty: formData.subcounty,
                occupants: parseInt(formData.occupants),
                capacity: parseInt(formData.capacity)
            };

            await createShelter(user.token, shelterData, profile.role_user);
            
            setSuccess(true);
            // Reset form
            setFormData({
                name: "",
                county: "",
                location: "",
                subcounty: "",
                occupants: "",
                capacity: ""
            });
            setSelectedLocation("");
            
            // Redirect after 2 seconds
            setTimeout(() => {
                navigate("/shelters");
            }, 2000);
        } catch (err) {
            setError(err.message || "Failed to register shelter. Please try again.");
            console.error('Error creating shelter:', err);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className={common.pageStack}>
            <h1 className={common.pageTitle}>Register Shelter</h1>

            {error && (
                <div className={styles.alertBox} style={{background: "#ffebee", color: "#c62828", padding: "12px 16px", borderRadius: "8px", marginBottom: "16px"}}>
                    {error}
                </div>
            )}

            {success && (
                <div className={styles.alertBox} style={{background: "#e8f5e9", color: "#2e7d32", padding: "12px 16px", borderRadius: "8px", marginBottom: "16px"}}>
                    Shelter registered successfully! Redirecting to shelters...
                </div>
            )}

            <div className={styles.formFrame}>
                <div className={styles.formCard}>
                    <h2 className={common.pageTitleCentered}>Shelter Registration</h2>

                    <form className={styles.formGrid} id="shelterForm" onSubmit={handleSubmit}>
                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>Shelter Name</span>
                            <input
                                className={styles.textInput}
                                type="text"
                                name="name"
                                value={formData.name}
                                onChange={handleInputChange}
                                required
                            />
                        </label>

                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>County</span>
                            <input
                                className={styles.textInput}
                                type="text"
                                name="county"
                                value={formData.county}
                                onChange={handleInputChange}
                                required
                            />
                        </label>

                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>Location Coordinates</span>
                            <input
                                className={styles.textInput}
                                type="text" 
                                name="location"
                                value={formData.location}
                                onChange={handleInputChange}
                                onClick={handleLocationClick}
                                placeholder={profile?.role_user === 'command' ? "Click to select location on map" : "Enter coordinates"}
                                readOnly={profile?.role_user === 'command'}
                                required
                            />
                            {profile?.role_user === 'command' && (
                                <span className={styles.fieldHint}>
                                    Click the input field to open the map and select a location
                                </span>
                            )}
                        </label>

                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>Subcounty</span>
                            <input
                                className={styles.textInput}
                                type="text"
                                name="subcounty"
                                value={formData.subcounty}
                                onChange={handleInputChange}
                                required
                            />
                        </label>

                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>Occupants</span>
                            <input
                                className={styles.textInput}
                                type="number"
                                name="occupants"
                                value={formData.occupants}
                                onChange={handleInputChange}
                                required
                            />
                        </label>

                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>Capacity</span>
                            <input
                                className={styles.textInput}
                                type="number"
                                name="capacity"
                                value={formData.capacity}
                                onChange={handleInputChange}
                                required
                            />
                        </label>
                    </form>

                    <div className={common.actionRowCentered}>
                        <button 
                            className={common.primaryActionWide} 
                            type="submit"
                            form="shelterForm"
                            disabled={loading || success}
                            style={{opacity: loading || success ? 0.6 : 1, cursor: loading || success ? "not-allowed" : "pointer"}}
                        >
                            {loading ? "Registering..." : "Register Shelter"}
                        </button>
                    </div>
                    {showMap && profile?.role_user === 'command' && (
                        <div className={styles.mapModal}>
                            <div className={styles.mapContainer}>
                                <div className={styles.mapHeader}>
                                    <h3>Select Shelter Location</h3>
                                    <button
                                        type="button"
                                        className={styles.closeButton}
                                        onClick={() => setShowMap(false)}
                                    >
                                        ×
                                    </button>
                                </div>
                                <div className={styles.mapCanvas}>
                                    <MapContainer
                                        center={[-1.2921, 36.8219]} // Nairobi coordinates as default
                                        zoom={10}
                                        style={{height: "300px", width: "100%"}}
                                    >
                                        <TileLayer
                                            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                                            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                                        />
                                        <LocationSelector
                                            onLocationSelect={handleLocationSelect}
                                            initialPosition={null}
                                        />
                                    </MapContainer>
                                </div>
                                <div className={styles.mapActions}>
                                    <button
                                        type="button"
                                        className={common.secondaryAction}
                                        onClick={() => setShowMap(false)}
                                    >
                                        Cancel
                                    </button>
                                    <button
                                        type="button"
                                        className={common.primaryAction}
                                        onClick={() => setShowMap(false)}
                                        disabled={!selectedLocation}
                                    >
                                        Confirm Location
                                    </button>
                                </div>
                            </div>
                        </div>
                    )}

                </div>
            </div>
        </div>
    );
};

export default AddShelter;
