import {MdOutlineErrorOutline, MdOutlineHomeWork, MdOutlinePayments} from "react-icons/md";
import common from "../../styles/views-common.module.css";
import styles from "../../styles/dashboard.module.css";

const metricCards = [
    {icon: MdOutlinePayments, value: "KES 200,000", label: "Total donations"},
    {icon: MdOutlineHomeWork, value: "87%", label: "Average occupancy"},
    {icon: MdOutlineErrorOutline, value: "10", label: "Active alerts"},
];

const shelterRows = [
    ["Thika Stadium", "Thika, Kiambu", "86", "Medicine"],
    ["Kisumu Jomo Kenyatta Ground", "Kisumu Central, Kisumu", "50", "Food, Water"],
    ["Madaraka Primary", "Langata, Nairobi", "70", "Food, Water"],
    ["Karura Forest Relief Camp", "Westlands, Nairobi", "70", "Food, Water"],
    ["Thika Level 5 Hospital", "Thika, Kiambu", "70", "Food, Water"],
    ["Nakuru ASK Showground", "Nakuru East, Nakuru", "70", "Food, Water"],
    ["Malindi Sports Ground", "Malindi Town, Kilifi", "70", "Food, Water"],
];

const Dashboard = () => {
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
                            <div className={styles.mapMarker}/>
                            <span className={styles.mapLabel}>Thika Stadium</span>
                        </div>
                    </div>

                    <div className={styles.tableCard}>
                        <h3 className={common.tableTitle}>Shelter Data</h3>
                        <table className={common.dataTable}>
                            <thead>
                            <tr>
                                <th>Shelter Name</th>
                                <th>Location</th>
                                <th>Occupancy (%)</th>
                                <th>Required resource status</th>
                            </tr>
                            </thead>
                            <tbody>
                            {shelterRows.map((row) => (
                                <tr key={row[0]}>
                                    {row.map((cell, index) => (
                                        <td key={`${row[0]}-${index}`}>{cell}</td>
                                    ))}
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
