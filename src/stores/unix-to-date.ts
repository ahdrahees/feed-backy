export function convertNanosecondsToReadableDate(unixTimeNanoString: string) {
	if (unixTimeNanoString === '0') {
		// avoiding no time arguments
		return '';
	}
	// Convert nanoseconds string to a number
	const unixTimeNano = parseInt(unixTimeNanoString, 10);

	// Convert nanoseconds to milliseconds
	const unixTimeMilliseconds = unixTimeNano / 1e6;

	// Create a new Date object using the Unix time in milliseconds
	const date = new Date(unixTimeMilliseconds);

	// Get individual components of the date (year, month, day, hour, minute)
	const year = date.getFullYear();
	const month = date.toLocaleString('en-US', { month: 'long' });
	const day = date.getDate();
	const hours = date.getHours();
	const minutes = date.getMinutes();

	// Determine if it's AM or PM
	const amOrPm = hours < 12 ? 'AM' : 'PM';

	// Convert hours to 12-hour format
	const formattedHours = hours % 12 || 12;

	// Format the date as a string
	const formattedDate = `${month} ${day}th ${year}, ${formattedHours}:${String(minutes).padStart(
		2,
		'0'
	)} ${amOrPm}`;

	return formattedDate;
}
