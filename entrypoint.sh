#!/bin/bash
# Merge image-baked skills into the (possibly host-mounted) skills directory.
# Host-installed skills take precedence: existing files are never overwritten.
SKILLS_SRC="/opt/opencode/skills"
SKILLS_DST="${HOME}/.config/opencode/skills"

if [ -d "${SKILLS_SRC}" ]; then
    mkdir -p "${SKILLS_DST}"
    for skill_dir in "${SKILLS_SRC}"/*/; do
        skill_name="$(basename "${skill_dir}")"
        dst_skill="${SKILLS_DST}/${skill_name}"
        mkdir -p "${dst_skill}"
        # Copy each file only if it does not already exist at the destination
        for src_file in "${skill_dir}"*; do
            [ -f "${src_file}" ] || continue
            dst_file="${dst_skill}/$(basename "${src_file}")"
            if [ ! -e "${dst_file}" ]; then
                cp "${src_file}" "${dst_file}"
            fi
        done
    done
fi

exec "$@"
