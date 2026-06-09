import {useEffect, useMemo, useState} from "react";
import {MdHistory, MdOutlinePlace, MdWaterDrop, MdMedicalServices, MdRestaurant} from "react-icons/md";
import common from "../../styles/views-common.module.css";
import {useAuth} from "../../context/AuthContext.jsx";
import {getResourceHistory} from "../../services/resource/resourceService";

const formatCounty = (county) =>
    county ? county.charAt(0).toUpperCase() + county.slice(1).toLowerCase() : "All counties";

const formatDateTime = (value) =>
    new Date(value).toLocaleString("en-KE", {
        year: "numeric",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
    });

const ResourceUpdates = () => {
    const {user, profile} = useAuth();
    const [resourceHistory, setResourceHistory] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const accessLabel = useMemo(() => {
        if (profile?.role_user === "manager") {
            return `${formatCounty(profile.county_work)} resource history`;
        }
        if (profile?.role_user === "command") {
            return "Country-wide resource history";
        }
        return "Resource history";
    }, [profile]);

    useEffect(() => {
        const fetchResources = async () => {
            if (!user?.token || !profile) return;

            if (profile.role_user !== "manager" && profile.role_user !== "command") {
                setError("You do not have permission to view resource history.");
                setLoading(false);
                return;
            }

            try {
                setLoading(true);
                setError(null);

                const data = await getResourceHistory(
                    user.token,
                    profile.role_user,
                    profile.county_work
                );
                setResourceHistory(data);
            } catch (err) {
                setError(err.message || "Failed to load resource history.");
                console.error("Error fetching resource history:", err);
            } finally {
                setLoading(false);
            }
        };

        fetchResources();
    }, [user, profile]);

    if (loading) {
        return (
            <div className={common.pageStack}>
                <h1 className={common.pageTitle}>Resource Updates</h1>
                <div className={common.loadingState}>Loading resource history...</div>
            </div>
        );
    }

    if (error) {
        return (
            <div className={common.pageStack}>
                <h1 className={common.pageTitle}>Resource Updates</h1>
                <div className={common.errorState}>Error: {error}</div>
            </div>
        );
    }

    return (
        <div className={common.pageStack}>
            <div className={common.pageHeaderRow}>
                <div>
                    <h1 className={common.pageTitle}>Resource Updates</h1>
                    <div className={common.fieldLabel}>{accessLabel}</div>
                </div>
                <div className={common.fieldLabel} style={{display: "flex", alignItems: "center", gap: 8}}>
                    <MdHistory/>
                    <span>{resourceHistory.length} updates</span>
                </div>
            </div>

            {resourceHistory.length === 0 ? (
                <div className={common.emptyStateContainer}>
                    <div className={common.emptyStateMessage}>No resource updates found</div>
                </div>
            ) : (
                <div className={common.tableShell}>
                    <table className={common.dataTable}>
                        <thead>
                            <tr>
                                <th>Shelter</th>
                                <th>Location</th>
                                <th>Food</th>
                                <th>Water</th>
                                <th>Medical</th>
                                <th>Notes</th>
                                <th>Updated</th>
                            </tr>
                        </thead>
                        <tbody>
                            {resourceHistory.map((resource) => (
                                <tr key={resource.resource_id}>
                                    <td>{resource.shelter_name}</td>
                                    <td>
                                        <MdOutlinePlace style={{verticalAlign: "text-bottom"}} />{" "}
                                        {resource.subcounty}, {resource.county}
                                    </td>
                                    <td>
                                        <MdRestaurant style={{verticalAlign: "text-bottom"}} />{" "}
                                        {resource.food}
                                    </td>
                                    <td>
                                        <MdWaterDrop style={{verticalAlign: "text-bottom"}} />{" "}
                                        {resource.water}
                                    </td>
                                    <td>
                                        <MdMedicalServices style={{verticalAlign: "text-bottom"}} />{" "}
                                        {resource.medical}
                                    </td>
                                    <td>{resource.add_notes || "None"}</td>
                                    <td>{formatDateTime(resource.updated_at)}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
};

export default ResourceUpdates;
