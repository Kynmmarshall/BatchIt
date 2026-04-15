const deploymentInfoUrl = "js/deployment-info.json";
let refreshTimer = null;
let lastBuildNumber = null;

function byId(id) {
	return document.getElementById(id);
}

function setText(id, value) {
	const node = byId(id);
	if (node) {
		node.textContent = value;
	}
}

function formatBytes(bytes) {
	if (!Number.isFinite(bytes) || bytes <= 0) {
		return "Unknown";
	}

	const units = ["B", "KB", "MB", "GB"];
	let size = bytes;
	let index = 0;

	while (size >= 1024 && index < units.length - 1) {
		size /= 1024;
		index += 1;
	}

	return `${size.toFixed(size >= 10 ? 1 : 2)} ${units[index]}`;
}

async function getFileSize(path) {
	try {
		const response = await fetch(`${path}?v=${Date.now()}`, { method: "HEAD", cache: "no-store" });
		if (!response.ok) {
			return "Unavailable";
		}

		const length = Number(response.headers.get("content-length"));
		return formatBytes(length);
	} catch (_error) {
		return "Unavailable";
	}
}

async function loadDeploymentInfo() {
	try {
		const response = await fetch(`${deploymentInfoUrl}?v=${Date.now()}`, { cache: "no-store" });
		if (!response.ok) {
			throw new Error("deployment metadata not found");
		}

		const data = await response.json();
		const buildNumber = data.build_number || "-";
		lastBuildNumber = buildNumber;

		setText("pipeline-status", "Healthy");
		setText("build-number", buildNumber);
		setText("build-number-detail", buildNumber);
		setText("deployed-at", data.deployed_at_cameroon || data.last_deployed || "-");
		setText("job-name", data.job_name || "-");

		const buildUrl = byId("build-url");
		if (buildUrl && data.build_url) {
			buildUrl.href = data.build_url;
		}

		const [apkSize, aabSize] = await Promise.all([
			getFileSize("download/BatchIt.apk"),
			getFileSize("download/BatchIt.aab")
		]);

		setText("apk-size", apkSize);
		setText("aab-size", aabSize);
	} catch (_error) {
		setText("pipeline-status", "Waiting for first deployment");
		setText("apk-size", "Unavailable");
		setText("aab-size", "Unavailable");
	}
}

async function refreshDeploymentInfo() {
	try {
		const response = await fetch(`${deploymentInfoUrl}?v=${Date.now()}`, { cache: "no-store" });
		if (!response.ok) {
			return;
		}

		const data = await response.json();
		const buildNumber = data.build_number || "-";

		if (buildNumber !== lastBuildNumber) {
			await loadDeploymentInfo();
		}
	} catch (_error) {
		// Ignore refresh errors and keep the last visible values.
	}
}

function wireCopyButtons() {
	const buttons = document.querySelectorAll("[data-copy-target]");
	buttons.forEach((button) => {
		button.addEventListener("click", async () => {
			const targetId = button.getAttribute("data-copy-target");
			const source = targetId ? byId(targetId) : null;
			if (!source) {
				return;
			}

			try {
				await navigator.clipboard.writeText(source.textContent || "");
				const original = button.textContent;
				button.textContent = "Copied";
				setTimeout(() => {
					button.textContent = original;
				}, 1200);
			} catch (_error) {
				button.textContent = "Copy failed";
			}
		});
	});
}

document.addEventListener("DOMContentLoaded", () => {
	wireCopyButtons();
	loadDeploymentInfo();
	refreshTimer = window.setInterval(loadDeploymentInfo, 30000);
});

document.addEventListener("visibilitychange", () => {
	if (!document.hidden) {
		loadDeploymentInfo();
	}
});
