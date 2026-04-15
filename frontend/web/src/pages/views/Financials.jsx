import {MdAccountBalanceWallet, MdOutlinePercent, MdVolunteerActivism} from "react-icons/md";
import {ArcElement, Chart as ChartJS, Legend, Tooltip} from "chart.js";
import {Pie} from "react-chartjs-2";
import common from "../../styles/views-common.module.css";
import shared from "../../styles/dashboard.module.css";
import styles from "../../styles/financials.module.css";

ChartJS.register(ArcElement, Tooltip, Legend);

const summaryCards = [
    {icon: MdAccountBalanceWallet, value: "KES 13,200,000", label: "Total funds received."},
    {icon: MdOutlinePercent, value: "12", label: "Budget deficit in percentage"},
    {icon: MdVolunteerActivism, value: "KES 2,000,000", label: "Donations received"},
];

const chartData = {
    labels: ["Government", "NGOs", "Donations", "Countries abroad"],
    datasets: [
        {
            data: [7, 2, 3, 1.2],
            backgroundColor: ["#7a6ae8", "#ff8a85", "#43b5cf", "#ffb24d"],
            borderWidth: 0,
        },
    ],
};

const chartOptions = {
    maintainAspectRatio: false,
    plugins: {
        legend: {
            position: "bottom",
            labels: {
                usePointStyle: true,
                boxWidth: 8,
                color: "#5f6770",
            },
        },
    },
};

const Financials = () => {
    return (
        <div className={common.pageStack}>
            <h1 className={common.pageTitle}>Financial Summaries</h1>

            <div className={styles.financialShell}>
                <div className={styles.financialGrid}>
                    <div className={styles.financialCardColumn}>
                        {summaryCards.map(({icon: Icon, value, label}) => (
                            <article key={label} className={styles.financialMetricCard}>
                                <Icon className={shared.metricIcon}/>
                                <strong className={shared.metricValue}>{value}</strong>
                                <span className={shared.metricLabel}>{label}</span>
                            </article>
                        ))}
                    </div>

                    <div className={styles.chartCard}>
                        <div className={styles.chartNote}>Unit: KES in millions ('000,000')</div>
                        <div className={styles.chartWrap}>
                            <Pie data={chartData} options={chartOptions}/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Financials;
