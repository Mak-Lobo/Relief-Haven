import {useEffect, useState} from "react";
import {useNavigate, useParams} from "react-router-dom";
import common from "../../styles/views-common.module.css";
import styles from "../../styles/shelter-form.module.css";
import {useAuth} from "../../context/AuthContext.jsx";
import {getShelterById, updateShelter} from "../../services/shelter/shelterService";

const UpdateShelter = () => {
    const {shelterId} = useParams();
    const navigate = useNavigate();
    const {user, profile} = useAuth();

    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState(null);
    const [success, setSuccess] = useState(false);
    const [shelterName, setShelterName] = useState("");
    const [formData, setFormData] = useState({
        name: "",
        county: "",
        subcounty: "",
        capacity: "",
    });

    useEffect(() => {
        const fetchShelter = async () => {
            if (!user?.token || !profile || !shelterId) return;

            try {
                setLoading(true);
                setError(null);

                const shelterData = await getShelterById(user.token, shelterId);
                setShelterName(shelterData.name ?? "");
                setFormData({
                    name: shelterData.name ?? "",
                    county: shelterData.county ?? "",
                    subcounty: shelterData.subcounty ?? "",
                    capacity: shelterData.capacity ?? "",
                });
            } catch (err) {
                setError(err.message || "Failed to load shelter details.");
                console.error("Error fetching shelter:", err);
            } finally {
                setLoading(false);
            }
        };

        fetchShelter();
    }, [user, profile, shelterId]);

    const handleInputChange = (event) => {
        const {name, value} = event.target;
        setFormData((prev) => ({
            ...prev,
            [name]: value,
        }));
    };

    const handleSubmit = async (event) => {
        event.preventDefault();

        if (!user?.token || !profile) {
            setError("Authentication failed. Please log in again.");
            return;
        }

        try {
            setSaving(true);
            setError(null);

            await updateShelter(
                user.token,
                shelterId,
                {
                    name: formData.name,
                    county: formData.county,
                    subcounty: formData.subcounty,
                    capacity: Number(formData.capacity),
                },
                profile.role_user
            );

            setSuccess(true);
            setTimeout(() => {
                navigate("/shelters");
            }, 1600);
        } catch (err) {
            setError(err.message || "Failed to update shelter details.");
            console.error("Error updating shelter:", err);
        } finally {
            setSaving(false);
        }
    };

    if (loading) {
        return (
            <div className={common.pageStack}>
                <h1 className={common.pageTitle}>Update Shelter</h1>
                <div className={common.loadingState}>Loading shelter details...</div>
            </div>
        );
    }

    return (
        <div className={common.pageStack}>
            <h1 className={common.pageTitle}>
                Update Shelter: {shelterName || "Selected Shelter"}
            </h1>

            {error && <div className={common.errorState}>Error: {error}</div>}

            {success && (
                <div className={common.loadingState}>
                    Shelter updated successfully. Redirecting...
                </div>
            )}

            <div className={styles.formFrame}>
                <div className={styles.formCard}>
                    <h2 className={common.pageTitleCentered}>
                        Shelter Details
                    </h2>

                    <form className={styles.formGrid} id="updateShelterForm" onSubmit={handleSubmit}>
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
                            <span className={common.fieldLabel}>Capacity</span>
                            <input
                                className={styles.textInput}
                                type="number"
                                name="capacity"
                                value={formData.capacity}
                                onChange={handleInputChange}
                                min="0"
                                required
                            />
                        </label>
                    </form>

                    <div className={common.actionRowCentered}>
                        <button
                            className={common.primaryActionWide}
                            type="submit"
                            form="updateShelterForm"
                            disabled={saving || success}
                            style={{
                                opacity: saving || success ? 0.6 : 1,
                                cursor: saving || success ? "not-allowed" : "pointer",
                            }}
                        >
                            {saving ? "Updating..." : "Update Shelter"}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default UpdateShelter;
