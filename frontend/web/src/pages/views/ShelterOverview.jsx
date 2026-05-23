import {useState, useEffect} from "react";
import {MdAdd, MdCheckCircle, MdClose, MdEdit} from "react-icons/md";
import {Link} from "react-router-dom";
import common from "../../styles/views-common.module.css";
import {useAuth} from "../../context/AuthContext.jsx";
import {
    getShelters,
    getSheltersByCounty,
    deactivateShelter,
    activateShelter,
} from "../../services/shelter/shelterService";

const ShelterOverview = () => {
    const {user, profile} = useAuth();
    const [shelters, setShelters] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const managerCounty = profile?.role_user === "manager" ? `${profile.county_work.charAt(0).toUpperCase()}${profile.county_work.slice(1).toLowerCase()}` : null;

    useEffect(() => {
        const fetchShelters = async () => {
            if (!user?.token || !profile) return;

            try {
                setLoading(true);
                const data = profile.role_user === "manager" && managerCounty
                    ? await getSheltersByCounty(user.token, managerCounty)
                    : await getShelters(user.token, profile.role_user, managerCounty);
                setShelters(data);
            } catch (err) {
                setError(err.message);
                console.error('Error fetching shelters:', err);
            } finally {
                setLoading(false);
            }
        };

        fetchShelters();
    }, [user, profile]);

    const handleDeactivateShelter = async (shelterId) => {
        if (!user?.token) return;

        if (!confirm('Are you sure you want to deactivate this shelter?')) return;

        try {
            await deactivateShelter(user.token, shelterId, profile.role_user);
            // Refresh the shelters list
            const data = profile.role_user === "manager" && managerCounty
                ? await getSheltersByCounty(user.token, managerCounty)
                : await getShelters(user.token, profile.role_user, managerCounty);
            setShelters(data);
        } catch (err) {
            setError(err.message);
            console.error('Error deactivating shelter:', err);
        }
    };

    const handleActivateShelter = async (shelterId) => {
        if (!user?.token) return;

        if (!confirm('Are you sure you want to activate this shelter?')) return;

        try {
            await activateShelter(user.token, shelterId, profile.role_user);
            const data = profile.role_user === "manager" && managerCounty
                ? await getSheltersByCounty(user.token, managerCounty)
                : await getShelters(user.token, profile.role_user, managerCounty);
            setShelters(data);
        } catch (err) {
            setError(err.message);
            console.error('Error activating shelter:', err);
        }
    };

    if (loading) {
        return (
            <div className={common.pageStack}>
                <h1 className={common.pageTitle}>Shelters</h1>
                <div className={common.loadingState}>Loading shelters...</div>
            </div>
        );
    }

    if (error) {
        return (
            <div className={common.pageStack}>
                <h1 className={common.pageTitle}>Shelters</h1>
                <div className={common.errorState}>Error: {error}</div>
            </div>
        );
    }

    return (
        <div className={common.pageStack}>
            <div className={common.pageHeaderRow}>
                <h1 className={common.pageTitle}>
                    {profile?.role_user === 'manager' ? `${profile.county_work.charAt(0).toUpperCase()}${profile.county_work.slice(1).toLowerCase()} County Shelters` : 'All Shelters'}
                </h1>
                {profile?.role_user === 'command' && (
                    <Link className={common.primaryAction} to="/shelters/add">
                        <MdAdd/>
                        <span>Register Shelter</span>
                    </Link>
                )}
            </div>

            {shelters.length === 0 ? (
                <div className={common.emptyStateContainer}>
                    <div className={common.emptyStateMessage}>
                        No shelters available
                    </div>
                </div>
            ) : (
                <div className={common.tableShell}>
                    <table className={common.dataTable}>
                        <thead>
                        <tr>
                            <th>Name</th>
                            <th>Location</th>
                            <th>Status</th>
                            <th>Occupants</th>
                            <th>Capacity</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        {shelters.map((shelter) => (
                            <tr key={shelter.shelter_id}>
                                <td>{shelter.name}</td>
                                <td>{shelter.subcounty}, {shelter.county}</td>
                                <td>{shelter.is_active ? 'Active' : 'Inactive'}</td>
                                <td>{shelter.occupancy}</td>
                                <td>{shelter.capacity}</td>
                                <td>
                                    <div className={common.tableActions}>
                                        {profile?.role_user === 'command' && (
                                            <>
                                                <Link
                                                    className={common.inlineAction}
                                                    to={`/shelters/update/${shelter.shelter_id}`}
                                                >
                                                    <MdEdit/>
                                                    <span>Edit</span>
                                                </Link>
                                                {shelter.is_active ? (
                                                    <button
                                                        className={common.inlineDanger}
                                                        type="button"
                                                        onClick={() => handleDeactivateShelter(shelter.shelter_id)}
                                                    >
                                                        <MdClose/>
                                                        <span>Deactivate</span>
                                                    </button>
                                                ) : (
                                                    <button
                                                        className={common.inlineAction}
                                                        type="button"
                                                        onClick={() => handleActivateShelter(shelter.shelter_id)}
                                                    >
                                                        <MdCheckCircle/>
                                                        <span>Activate</span>
                                                    </button>
                                                )}
                                            </>
                                        )}
                                        {profile?.role_user === 'manager' && (
                                            <Link
                                                className={common.inlineAction}
                                                to={`/shelters/resources/${shelter.shelter_id}`}
                                                state={{
                                                    shelterName: shelter.name,
                                                    capacity: shelter.capacity,
                                                }}
                                            >
                                                <MdEdit/>
                                                <span>Update Resources</span>
                                            </Link>
                                        )}
                                    </div>
                                </td>
                            </tr>
                        ))}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
};

export default ShelterOverview;
