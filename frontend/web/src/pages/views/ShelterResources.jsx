import {useEffect, useState} from "react";
import {useLocation, useNavigate, useParams} from "react-router-dom";
import Slider from "rc-slider";
import "rc-slider/assets/index.css";
import common from "../../styles/views-common.module.css";
import styles from "../../styles/shelter-form.module.css";
import {useAuth} from "../../context/AuthContext.jsx";
import {
    getShelterById,
    createShelterResource,
    updateShelterOccupancy,
} from "../../services/shelter/shelterService";

const sliderTheme = {
    trackStyle: {backgroundColor: "var(--primary)", height: 8},
    railStyle: {backgroundColor: "var(--primary-container)", height: 8},
    handleStyle: {
        borderColor: "var(--secondary)",
        backgroundColor: "var(--secondary)",
        opacity: 1,
        width: 16,
        height: 16,
        marginTop: -4,
    },
};

const defaultResourceForm = {
    food: 0,
    water: 0,
    medical: 0,
    add_notes: "",
};

const ShelterResources = () => {
    const {shelterId} = useParams();
    const location = useLocation();
    const navigate = useNavigate();
    const {user, profile} = useAuth();

    const [shelter, setShelter] = useState(null);
    const [occupancy, setOccupancy] = useState(0);
    const [formData, setFormData] = useState(defaultResourceForm);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState(null);
    const [success, setSuccess] = useState(false);
    const selectedShelterName = location.state?.shelterName ?? shelter?.name ?? "Selected Shelter";
    const selectedShelterCapacity = location.state?.capacity ?? shelter?.capacity ?? 0;

    useEffect(() => {
        const fetchShelterData = async () => {
            if (!user?.token || !profile || !shelterId) return;

            try {
                setLoading(true);
                setError(null);

                const shelterData = await getShelterById(user.token, shelterId);

                setShelter(shelterData);
                setOccupancy(shelterData.occupancy ?? 0);
                setFormData(defaultResourceForm);
            } catch (err) {
                setError(err.message || "Failed to load shelter data.");
                console.error("Error fetching shelter data:", err);
            } finally {
                setLoading(false);
            }
        };

        fetchShelterData();
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

            await updateShelterOccupancy(
                user.token,
                shelterId,
                {occupancy: Number(occupancy)},
                profile.role_user
            );

            const resourcePayload = {
                shelter_id: shelterId,
                food: Number(formData.food),
                water: Number(formData.water),
                medical: Number(formData.medical),
                add_notes: formData.add_notes.trim() ? formData.add_notes.trim() : null,
            };

            await createShelterResource(
                user.token,
                resourcePayload,
                profile.role_user
            );

            setSuccess(true);
            setTimeout(() => {
                navigate("/shelters");
            }, 1600);
        } catch (err) {
            setError(err.message || "Failed to update shelter resources.");
            console.error("Error updating shelter resources:", err);
        } finally {
            setSaving(false);
        }
    };

    if (loading) {
        return (
            <div className={common.pageStack}>
                <h1 className={common.pageTitle}>Update Resources</h1>
                <div className={common.loadingState}>Loading shelter resources...</div>
            </div>
        );
    }

    return (
        <div className={common.pageStack}>
            <h1 className={common.pageTitle}>
                Update Resources: {selectedShelterName}
            </h1>

            {error && <div className={common.errorState}>Error: {error}</div>}

            {success && (
                <div className={common.loadingState}>
                    Shelter resources updated successfully. Redirecting...
                </div>
            )}

            <div className={styles.formFrame}>
                <div className={styles.formCard}>
                    <h2 className={common.pageTitleCentered}>
                        {selectedShelterName}
                    </h2>
                    <div className={common.fieldLabel} style={{marginTop: "-8px", textAlign: "center"}}>
                        Capacity: {selectedShelterCapacity || "N/A"} | Current occupancy: {occupancy}
                    </div>

                    <form className={styles.formGrid} id="resourceForm" onSubmit={handleSubmit}>
                        <div className={styles.sliderGroup} style={{gridColumn: "1 / -1"}}>
                            <div className={styles.sliderHeaderRow}>
                                <h3 className={styles.sliderSectionTitle}>Occupancy Update</h3>
                                <div className={styles.sliderPillMeta}>
                                    <span className={styles.sliderMeta}>
                                        {selectedShelterCapacity ? `${occupancy}/${selectedShelterCapacity} people` : "People"}
                                    </span>
                                    <div className={styles.valuePill}>{occupancy}</div>
                                </div>
                            </div>
                            <Slider
                                min={0}
                                max={Number(selectedShelterCapacity) || Math.max(Number(occupancy) || 0, 100)}
                                value={Number(occupancy)}
                                onChange={(value) => setOccupancy(value)}
                                {...sliderTheme}
                            />
                        </div>

                        <div className={styles.sliderGroup} style={{gridColumn: "1 / -1"}}>
                            <div className={styles.sliderHeaderRow}>
                                <h3 className={styles.sliderSectionTitle}>Food Resource</h3>
                                <div className={styles.sliderPillMeta}>
                                    <span className={styles.sliderMeta}>Kilograms</span>
                                    <div className={styles.valuePill}>{formData.food}</div>
                                </div>
                            </div>
                            <Slider
                                min={0}
                                max={Math.max(100, Number(formData.food) || 0)}
                                value={Number(formData.food)}
                                onChange={(value) => setFormData((prev) => ({...prev, food: value}))}
                                {...sliderTheme}
                            />
                        </div>

                        <div className={styles.sliderGroup} style={{gridColumn: "1 / -1"}}>
                            <div className={styles.sliderHeaderRow}>
                                <h3 className={styles.sliderSectionTitle}>Water Resource</h3>
                                <div className={styles.sliderPillMeta}>
                                    <span className={styles.sliderMeta}>Liters</span>
                                    <div className={styles.valuePill}>{formData.water}</div>
                                </div>
                            </div>
                            <Slider
                                min={0}
                                max={Math.max(500, Number(formData.water) || 0)}
                                value={Number(formData.water)}
                                onChange={(value) => setFormData((prev) => ({...prev, water: value}))}
                                {...sliderTheme}
                            />
                        </div>

                        <div className={styles.sliderGroup} style={{gridColumn: "1 / -1"}}>
                            <div className={styles.sliderHeaderRow}>
                                <h3 className={styles.sliderSectionTitle}>Medical Resource</h3>
                                <div className={styles.sliderPillMeta}>
                                    <span className={styles.sliderMeta}>Kilograms</span>
                                    <div className={styles.valuePill}>{formData.medical}</div>
                                </div>
                            </div>
                            <Slider
                                min={0}
                                max={Math.max(100, Number(formData.medical) || 0)}
                                value={Number(formData.medical)}
                                onChange={(value) => setFormData((prev) => ({...prev, medical: value}))}
                                {...sliderTheme}
                            />
                        </div>

                        <label className={styles.formField} style={{gridColumn: "1 / -1"}}>
                            <span className={common.fieldLabel}>Additional Notes (optional)</span>
                            <textarea
                                className={styles.textArea}
                                name="add_notes"
                                value={formData.add_notes}
                                onChange={handleInputChange}
                                placeholder="Add anything the response team should know..."
                                rows={4}
                            />
                        </label>
                    </form>

                    <div className={common.actionRowCentered}>
                        <button
                            className={common.primaryActionWide}
                            type="submit"
                            form="resourceForm"
                            disabled={saving || success}
                            style={{
                                opacity: saving || success ? 0.6 : 1,
                                cursor: saving || success ? "not-allowed" : "pointer",
                            }}
                        >
                            {saving ? "Updating..." : "Update Resources"}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default ShelterResources;
