import {useEffect, useMemo, useState} from "react";
import {MapContainer, Marker, Popup, TileLayer} from "react-leaflet";
import {divIcon} from "leaflet";
import "leaflet/dist/leaflet.css";
import {MdOutlineErrorOutline, MdOutlineHomeWork, MdOutlinePayments} from "react-icons/md";
import common from "../../styles/views-common.module.css";
import styles from "../../styles/dashboard.module.css";
import {useAuth} from "../../context/AuthContext.jsx";
import {getShelters} from "../../services/shelter/shelterService";

const metricCards = [
    {icon: MdOutlinePayments, value: "KES 200,000", label: "Total donations"},
    {icon: MdOutlineHomeWork, value: "87%", label: "Average occupancy"},
    {icon: MdOutlineErrorOutline, value: "10", label: "Active alerts"},
];

const parsePoint = (value) => {
    const match = value?.match(/^POINT\(([-\d.]+)\s+([-\d.]+)\)$/);
    if (!match) return null;
    const lng = Number(match[1]);
    const lat = Number(match[2]);
    return Number.isFinite(lat) && Number.isFinite(lng) ? [lat, lng] : null;
};

const shelterPin = divIcon({
    className: "",
    html: '<div style="width:14px;height:14px;border-radius:999px;background:var(--error);border:3px solid white;box-shadow:0 0 0 6px rgb(from var(--error) r g b / 0.18)"></div>',
    iconSize: [20, 20],
    iconAnchor: [10, 10],
});

const Dashboard = () => {
    const {user} = useAuth();
    const [shelters, setShelters] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const loadShelters = async () => {
            if (!user?.token) return;

            try {
                setLoading(true);
                const data = await getShelters(user.token);
                setShelters(data);
            } catch (error) {
                console.error("Error loading shelters:", error);
            } finally {
                setLoading(false);
            }
        };

        loadShelters();
    }, [user]);

    const shelterMarkers = useMemo(
        () => shelters
            .map((shelter) => ({...shelter, coordinates: parsePoint(shelter.location)}))
            .filter((shelter) => shelter.coordinates),
        [shelters]
    );

    const tableRows = useMemo(
        () => shelters.map((shelter) => [
            shelter.name,
            `${shelter.subcounty}, ${shelter.county}`,
            shelter.capacity,
            shelter.occupancy,
            shelter.is_active ? "Active" : "Inactive",
            shelter.updated_at,
        ]),
        [shelters]
    );

    const mapCenter = shelterMarkers[0]?.coordinates ?? [-1.286389, 36.817223];

    return (
        <div className={common.pageStack}>
            <div className={styles.metricsGrid}>
                {metricCards.map(({icon: Icon, value, label}) => {
                    return (
                        <article key={label} className={styles.metricCard}>
                            <Icon className={styles.metricIcon}/>
                            <strong className={styles.metricValue}>{value}</strong>
                            <span className={styles.metricLabel}>{label}</span>
                        </article>
                    );
                })}
            </div>

            <div className={styles.sectionDivider}/>

            <section className={styles.sectionBlock}>
                <h2 className={common.sectionTitle}>Shelter information</h2>

                <div className={styles.dashboardGrid}>
                    <div className={styles.mapCard}>
                        <div className={styles.mapCanvas}>
                            {loading ? (
                                <div className={styles.mapLoading}>Loading shelter locations...</div>
                            ) : (
                                <MapContainer
                                    center={mapCenter}
                                    zoom={7}
                                    scrollWheelZoom={false}
                                    className={styles.mapStage}
                                >
                                    <TileLayer
                                        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                                        attribution='&copy; OpenStreetMap contributors'
                                    />
                                    {shelterMarkers.map((shelter) => (
                                        <Marker
                                            key={shelter.shelter_id}
                                            position={shelter.coordinates}
                                            icon={shelterPin}
                                        >
                                            <Popup>
                                                <strong>{shelter.name}</strong>
                                                <br />
                                                {shelter.subcounty}, {shelter.county}
                                                <br />
                                                Capacity: {shelter.capacity}
                                            </Popup>
                                        </Marker>
                                    ))}
                                </MapContainer>
                            )}
                        </div>
                    </div>

                    <div className={styles.tableCard}>
                        <h3 className={common.tableTitle}>Registered Shelters</h3>
                        <table className={common.dataTable}>
                            <thead>
                            <tr>
                                <th>Name</th>
                                <th>Location</th>
                                <th>Capacity</th>
                                <th>Occupancy</th>
                                <th>Status</th>
                                <th>Updated</th>
                            </tr>
                            </thead>
                            <tbody>
                            {tableRows.map((row) => (
                                <tr key={row[0]}>
                                    <td>{row[0]}</td>
                                    <td>{row[1]}</td>
                                    <td>{row[2]}</td>
                                    <td>{row[3]}</td>
                                    <td>{row[4]}</td>
                                    <td>{new Date(row[5]).toLocaleString()}</td>
                                </tr>
                            ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </div>
    );
};

export default Dashboard;
