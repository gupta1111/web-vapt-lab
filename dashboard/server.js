const express = require("express");
const path = require("path");
const fs = require("fs");

const app = express();

const PORT = 4000;

const findingsPath = path.join(
    __dirname,
    "data",
    "findings.json"
);

/* =========================================
   MIDDLEWARE
========================================= */

app.use(express.json());

app.use(
    express.static(
        path.join(__dirname, "public")
    )
);


/* =========================================
   HELPER FUNCTIONS
========================================= */

function readFindings() {

    try {

        if (!fs.existsSync(findingsPath)) {

            fs.writeFileSync(
                findingsPath,
                "[]"
            );

        }

        return JSON.parse(
            fs.readFileSync(
                findingsPath,
                "utf8"
            )
        );

    } catch (error) {

        console.error(
            "Read findings error:",
            error
        );

        return [];

    }

}


function saveFindings(findings) {

    fs.writeFileSync(
        findingsPath,
        JSON.stringify(
            findings,
            null,
            2
        )
    );

}


function generateFindingId(findings) {

    let highestNumber = 0;

    findings.forEach(
        finding => {

            const match =
                String(
                    finding.id || ""
                ).match(
                    /^F-(\d+)$/
                );

            if (match) {

                const number =
                    parseInt(
                        match[1],
                        10
                    );

                if (
                    number >
                    highestNumber
                ) {

                    highestNumber =
                        number;

                }

            }

        }
    );

    return `F-${String(
        highestNumber + 1
    ).padStart(2, "0")}`;

}


/* =========================================
   HEALTH CHECK
========================================= */

app.get(
    "/api/health",
    (req, res) => {

        res.json({

            status: "online",

            application:
                "AI VAPT Dashboard",

            version:
                "1.1.0"

        });

    }
);


/* =========================================
   GET ALL FINDINGS
========================================= */

app.get(
    "/api/findings",
    (req, res) => {

        try {

            const findings =
                readFindings();

            res.json({

                success: true,

                count:
                    findings.length,

                findings:
                    findings

            });

        } catch (error) {

            console.error(
                "Get findings error:",
                error
            );

            res.status(500).json({

                success: false,

                error:
                    "Unable to load findings"

            });

        }

    }
);


/* =========================================
   GET SINGLE FINDING
========================================= */

app.get(
    "/api/findings/:id",
    (req, res) => {

        try {

            const findings =
                readFindings();

            const finding =
                findings.find(
                    item =>
                        item.id ===
                        req.params.id
                );

            if (!finding) {

                return res.status(404).json({

                    success: false,

                    error:
                        "Finding not found"

                });

            }

            res.json({

                success: true,

                finding:
                    finding

            });

        } catch (error) {

            console.error(
                "Get finding error:",
                error
            );

            res.status(500).json({

                success: false,

                error:
                    "Unable to load finding"

            });

        }

    }
);


/* =========================================
   ADD FINDING
========================================= */

app.post(
    "/api/findings",
    (req, res) => {

        try {

            const finding =
                req.body;

            if (
                !finding.title ||
                !finding.severity ||
                !finding.endpoint
            ) {

                return res.status(400).json({

                    success: false,

                    error:
                        "Title, severity and endpoint are required"

                });

            }


            const findings =
                readFindings();


            const newFinding = {

                id:
                    finding.id ||
                    generateFindingId(
                        findings
                    ),

                title:
                    finding.title,

                endpoint:
                    finding.endpoint,

                parameter:
                    finding.parameter ||
                    "",

                severity:
                    finding.severity,

                status:
                    finding.status ||
                    "Open",

                retest:
                    finding.retest ||
                    "Pending",

                owasp:
                    finding.owasp ||
                    "",

                cwe:
                    finding.cwe ||
                    "",

                description:
                    finding.description ||
                    "",

                impact:
                    finding.impact ||
                    "",

                rootCause:
                    finding.rootCause ||
                    "",

                evidence:
                    finding.evidence ||
                    "",

                remediation:
                    finding.remediation ||
                    "",

                retestResult:
                    finding.retestResult ||
                    "",

                createdAt:
                    new Date().toISOString(),

                updatedAt:
                    new Date().toISOString()

            };


            findings.push(
                newFinding
            );


            saveFindings(
                findings
            );


            res.status(201).json({

                success: true,

                message:
                    "Finding added successfully",

                finding:
                    newFinding

            });

        } catch (error) {

            console.error(
                "Add finding error:",
                error
            );

            res.status(500).json({

                success: false,

                error:
                    "Unable to add finding"

            });

        }

    }
);


/* =========================================
   UPDATE FINDING
========================================= */

app.put(
    "/api/findings/:id",
    (req, res) => {

        try {

            const findings =
                readFindings();


            const index =
                findings.findIndex(
                    item =>
                        item.id ===
                        req.params.id
                );


            if (index === -1) {

                return res.status(404).json({

                    success: false,

                    error:
                        "Finding not found"

                });

            }


            const currentFinding =
                findings[index];


            const updatedFinding = {

                ...currentFinding,

                ...req.body,

                id:
                    currentFinding.id,

                updatedAt:
                    new Date().toISOString()

            };


            if (
                !updatedFinding.title ||
                !updatedFinding.severity ||
                !updatedFinding.endpoint
            ) {

                return res.status(400).json({

                    success: false,

                    error:
                        "Title, severity and endpoint are required"

                });

            }


            findings[index] =
                updatedFinding;


            saveFindings(
                findings
            );


            res.json({

                success: true,

                message:
                    "Finding updated successfully",

                finding:
                    updatedFinding

            });

        } catch (error) {

            console.error(
                "Update finding error:",
                error
            );

            res.status(500).json({

                success: false,

                error:
                    "Unable to update finding"

            });

        }

    }
);


/* =========================================
   RETEST FINDING
========================================= */

app.patch(
    "/api/findings/:id/retest",
    (req, res) => {

        try {

            const findings =
                readFindings();


            const index =
                findings.findIndex(
                    item =>
                        item.id ===
                        req.params.id
                );


            if (index === -1) {

                return res.status(404).json({

                    success: false,

                    error:
                        "Finding not found"

                });

            }


            const {
                retest,
                retestResult,
                status
            } = req.body;


            findings[index].retest =
                retest ||
                findings[index].retest ||
                "Pending";


            findings[index].retestResult =
                retestResult ||
                findings[index].retestResult ||
                "";


            if (status) {

                findings[index].status =
                    status;

            } else if (
                retest === "PASS"
            ) {

                findings[index].status =
                    "Fixed";

            } else if (
                retest === "FAIL"
            ) {

                findings[index].status =
                    "Open";

            } else {

                findings[index].status =
                    "Retest";

            }


            findings[index].updatedAt =
                new Date().toISOString();


            saveFindings(
                findings
            );


            res.json({

                success: true,

                message:
                    "Retest updated successfully",

                finding:
                    findings[index]

            });

        } catch (error) {

            console.error(
                "Retest error:",
                error
            );

            res.status(500).json({

                success: false,

                error:
                    "Unable to update retest"

            });

        }

    }
);


/* =========================================
   DELETE FINDING
========================================= */

app.delete(
    "/api/findings/:id",
    (req, res) => {

        try {

            const findings =
                readFindings();


            const index =
                findings.findIndex(
                    item =>
                        item.id ===
                        req.params.id
                );


            if (index === -1) {

                return res.status(404).json({

                    success: false,

                    error:
                        "Finding not found"

                });

            }


            const deletedFinding =
                findings[index];


            findings.splice(
                index,
                1
            );


            saveFindings(
                findings
            );


            res.json({

                success: true,

                message:
                    "Finding deleted successfully",

                finding:
                    deletedFinding

            });

        } catch (error) {

            console.error(
                "Delete finding error:",
                error
            );

            res.status(500).json({

                success: false,

                error:
                    "Unable to delete finding"

            });

        }

    }
);


/* =========================================
   START SERVER
========================================= */

app.listen(
    PORT,
    "127.0.0.1",
    () => {

        console.log(
            `AI VAPT Dashboard running at http://127.0.0.1:${PORT}`
        );

    }
);
