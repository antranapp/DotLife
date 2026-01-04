# Milestone 07 — Detail screen (full-screen) + list + momentType label + add CTA

## Goal
Implement the full Detail experience:
- Full-screen presentation
- Vertical list of experiences (newest-first)
- **momentType label visible by default** per row
- “Add an experience” CTA from detail

## Scope
- `ExperienceDetailView`
- `ExperienceRowView`
- Repository fetch by bucket
- Add CTA opens Capture flow (or a lightweight add sheet) and returns to detail

## Tasks
- [ ] Implement bucket-based fetch and bind to detail list
- [ ] Implement row rendering for note/link/dot (photo can come later)
- [ ] Show momentType label (tiny mono) in each row by default
- [ ] Add CTA to create new experience and return to detail

## Verifiable output
- Tap dot → full-screen detail shows correct items
- momentType label visible and correct
- Add from detail creates new item and list updates

## Acceptance criteria checklist
- [ ] Detail is full-screen and can be dismissed
- [ ] Items ordered newest-first
- [ ] Each item shows momentType label by default
- [ ] Add CTA adds a new experience with correct timestamp and chosen momentType
- [ ] List refreshes after add
